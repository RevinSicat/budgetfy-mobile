import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../local/local_database.dart';
import '../../common/utils/device_id_.dart';

class SyncService {
    final LocalDatabase _db;
    final SupabaseClient _sbdb;

    SyncService(this._db) : _sbdb = Supabase.instance.client;

    static const String _syncLogKey = 'sync_log';

    // =============================================================================================
    // Public API
    // =============================================================================================

    Future<void> syncAll() async {
        try {
            await _pull();
            await _push();
        } catch (e) {
            print('[SyncService.syncAll error]: $e');
            rethrow;
        }
    }

    Future<void> pushPending() async {
        try {
            await _push();
        } catch (e) {
            print('[SyncService.pushPending error]: $e');
            rethrow;
        }
    }

    // =============================================================================================
    // Outbox Writer — called by services on every mutation
    // =============================================================================================

    Future<void> writeToOutbox({
        required String tableName,
        required String recordId,
        required String operation,
        required Map<String, dynamic> payload,
    }) async {
        await _db.outboxDao.insertEntry(OutboxCompanion.insert(
            id: const Uuid().v4(),
            tblName: tableName,
            recordId: recordId,
            operation: operation,
            payload: jsonEncode(payload),
            createdAt: DateTime.now(),
        ));
    }

    // =============================================================================================
    // Pull — Supabase sync_log → Drift
    // =============================================================================================

    Future<void> _pull() async {
        final deviceId = await DeviceId.get();
        final lastSync = await _db.syncMetaDao.getLastSyncedAtByTable(_syncLogKey);
        final since = lastSync?.subtract(const Duration(seconds: 60));

        // Build filter first, then order — gte() is only available on PostgrestFilterBuilder
        var query = _sbdb
            .from('sync_log')
            .select();

        if (since != null) {
            query = query.gte('created_at', since.toIso8601String());
        }

        // Order AFTER filtering
        final rows = await query.order('created_at', ascending: true) as List;

        for (final row in rows) {
            if (row['device_id'] == deviceId) continue;
            await _applyRemoteOperation(row);
        }

        await _db.syncMetaDao.upsertLastSyncedAt(_syncLogKey, DateTime.now());
    }

    Future<void> _applyRemoteOperation(Map<String, dynamic> row) async {
        final table     = row['table_name'] as String;
        final operation = row['operation'] as String;
        final payload   = jsonDecode(row['payload'] as String) as Map<String, dynamic>;
        final recordId  = row['record_id'] as String;

        // Conflict check for updates — keep local if it has pending unsynced changes
        // that are newer than the incoming remote change
        if (operation == 'update') {
            final hasConflict = await _checkConflict(table, recordId, payload);
            if (hasConflict) return;
        }

        switch (table) {
            case 'transactions':
                await _applyTransaction(operation, payload);
            case 'accounts':
                await _applyAccount(operation, payload);
            case 'categories':
                await _applyCategory(operation, payload);
            case 'subcategories':
                await _applySubcategory(operation, payload);
        }
    }

    /// Returns true if local record is newer and has pending changes — skip remote
    Future<bool> _checkConflict(
        String table,
        String recordId,
        Map<String, dynamic> remotePayload,
    ) async {
        final remoteUpdatedAt = DateTime.parse(remotePayload['updated_at'] as String);

        switch (table) {
            case 'transactions':
                final local = await _db.transactionDao.getTransactionById(recordId);
                if (local != null
                    && local.pendingSync
                    && local.updatedAt.isAfter(remoteUpdatedAt)) {
                    print('[SyncService] conflict on transaction $recordId — keeping local');
                    return true;
                }
            case 'accounts':
                final local = await _db.accountDao.getAccountById(recordId);
                if (local != null
                    && local.pendingSync
                    && local.updatedAt.isAfter(remoteUpdatedAt)) {
                    print('[SyncService] conflict on account $recordId — keeping local');
                    return true;
                }
            case 'categories':
                final local = await _db.categoryDao.getCategoryById(recordId);
                if (local != null
                    && local.pendingSync
                    && local.updatedAt.isAfter(remoteUpdatedAt)) {
                    print('[SyncService] conflict on category $recordId — keeping local');
                    return true;
                }
        }
        return false;
    }

    Future<void> _applyTransaction(String operation, Map<String, dynamic> p) async {
        if (operation == 'delete') {
            await _db.transactionDao.softDeleteTransactionById(p['id'] as String);
            return;
        }
        await _db.transactionDao.saveTransaction(TransactionsCompanion.insert(
            id:              p['id'] as String,
            accountId:       p['account_id'] as String,
            categoryId:      p['category_id'] as String,
            subcategoryId:   Value(p['subcategory_id'] as String?),
            amount:          (p['amount'] as num).toDouble(),
            date:            DateTime.parse(p['date'] as String),
            transactionType: p['transaction_type'] as String,
            note:            Value(p['note'] as String? ?? ''),
            updatedAt:       Value(DateTime.parse(p['updated_at'] as String)),
            isDeleted:       Value(p['is_deleted'] as bool? ?? false),
            pendingSync:     const Value(false),
        ));
    }

    Future<void> _applyAccount(String operation, Map<String, dynamic> p) async {
        if (operation == 'delete') {
            await _db.accountDao.softDeleteAccountById(p['id'] as String);
            return;
        }
        await _db.accountDao.saveAccount(AccountsCompanion.insert(
            id:          p['id'] as String,
            name:        p['name'] as String,
            color:       p['color'] as String,
            updatedAt:   Value(DateTime.parse(p['updated_at'] as String)),
            isDeleted:   Value(p['is_deleted'] as bool? ?? false),
            pendingSync: const Value(false),
        ));
    }

    Future<void> _applyCategory(String operation, Map<String, dynamic> p) async {
        if (operation == 'delete') {
            await _db.categoryDao.softDeleteCategoryById(p['id'] as String);
            return;
        }
        await _db.categoryDao.saveCategory(CategoriesCompanion.insert(
            id:          p['id'] as String,
            name:        p['name'] as String,
            color:       p['color'] as String,
            type:        p['type'] as String,
            updatedAt:   Value(DateTime.parse(p['updated_at'] as String)),
            isDeleted:   Value(p['is_deleted'] as bool? ?? false),
            pendingSync: const Value(false),
        ));
    }

    Future<void> _applySubcategory(String operation, Map<String, dynamic> p) async {
        if (operation == 'delete') {
            await _db.subcategoryDao.softDeleteSubcategoryById(p['id'] as String);
            return;
        }
        await _db.subcategoryDao.saveSubcategory(SubcategoriesCompanion.insert(
            id:          p['id'] as String,
            categoryId:  p['category_id'] as String,
            name:        p['name'] as String,
            updatedAt:   Value(DateTime.parse(p['updated_at'] as String)),
            isDeleted:   Value(p['is_deleted'] as bool? ?? false),
            pendingSync: const Value(false),
        ));
    }

    // =============================================================================================
    // Push — Drift outbox → Supabase sync_log
    // =============================================================================================

    Future<void> _push() async {
        final pending = await _db.outboxDao.getAllUnsynced();
        if (pending.isEmpty) return;

        final deviceId = await DeviceId.get();

        final batch = pending.map((entry) => {
            'id':         entry.id,
            'device_id':  deviceId,
            'table_name': entry.tblName,
            'record_id':  entry.recordId,
            'operation':  entry.operation,
            'payload':    entry.payload,
            'created_at': entry.createdAt.toIso8601String(),
        }).toList();

        await _sbdb.from('sync_log').upsert(batch);

        final ids = pending.map((e) => e.id).toList();
        await _db.outboxDao.markSyncedByIds(ids);

        // Cleanup old synced entries to keep outbox table small
        await _db.outboxDao.deleteSynced();
    }
}