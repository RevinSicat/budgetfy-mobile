import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../local/local_database.dart';

class SyncService {
    final LocalDatabase _db;
    final SupabaseClient _sbdb;

    SyncService(this._db) : _sbdb = Supabase.instance.client;

    // Table key constants — used in SyncMeta to track per-table sync timestamps
    static const String accountsKey = 'accounts';
    static const String categoriesKey = 'categories';
    static const String subcategoriesKey = 'subcategories';
    static const String transactionsKey = 'transactions';

    // =============================================================================================
    // Connectivity helper
    // =============================================================================================

    Future<bool> get isOnline async {
        final result = await Connectivity().checkConnectivity();
        return result != ConnectivityResult.none;
    }

    // =============================================================================================
    // Public API
    // =============================================================================================

    Future<void> syncAll() async {
        try {
            await pushPending();
            await pullAccounts();
            await pullCategories();
            await pullSubcategories();
            await pullTransactions();
        } catch (e) {
            print('[SyncService.syncAll error]: $e');
            rethrow;
        }
    }
    Future<void> pushRecordNow() async {
        if (!await isOnline) return;
        try {
            await pushPending();
        } catch (e) {
            print('[SyncService.pushRecordNow error]: $e');
            // intentional silent fail — pendingSync flag ensures retry
        }
    }

    // =============================================================================================
    // Pull — Supabase → Drift
    // =============================================================================================

    Future<void> pullAccounts() async {
        final lastSync = await _db.syncMetaDao.getLastSyncedAtByTable(accountsKey);
        final nowUtc = DateTime.now().toUtc();

        var query = _sbdb.from('accounts').select();
        if (lastSync != null) {
            query = query.gte('updated_at', lastSync.toUtc().toIso8601String());
        }

        final response = await query as List;

        for (final row in response) {
            await _db.accountDao.saveAccount(AccountsCompanion.insert(
                id: row['id'] as String,
                name: row['name'] as String,
                color: row['color'] as String,
                updatedAt: Value(DateTime.parse(row['updated_at'] as String).toUtc()),
                isDeleted: Value(row['is_deleted'] as bool? ?? false),
                pendingSync: const Value(false)
            ));
        }

        await _db.syncMetaDao.upsertLastSyncedAt(accountsKey, nowUtc);
    }
    Future<void> pullCategories() async {
        final lastSync = await _db.syncMetaDao.getLastSyncedAtByTable(categoriesKey);
        final nowUtc = DateTime.now().toUtc();

        var query = _sbdb.from('categories').select();
        if (lastSync != null) {
            query = query.gte('updated_at', lastSync.toUtc().toIso8601String());
        }

        final response = await query as List;

        for (final row in response) {
            await _db.categoryDao.saveCategory(CategoriesCompanion.insert(
                id: row['id'] as String,
                name: row['name'] as String,
                color: row['color'] as String,
                type: row['type'] as String,
                updatedAt: Value(DateTime.parse(row['updated_at'] as String).toUtc()),
                isDeleted: Value(row['is_deleted'] as bool? ?? false),
                pendingSync: const Value(false),
            ));
        }

        await _db.syncMetaDao.upsertLastSyncedAt(categoriesKey, nowUtc);
    }
    Future<void> pullSubcategories() async {
        final lastSync = await _db.syncMetaDao.getLastSyncedAtByTable(subcategoriesKey);
        final nowUtc = DateTime.now().toUtc();

        var query = _sbdb.from('subcategories').select();
        if (lastSync != null) {
            query = query.gte('updated_at', lastSync.toUtc().toIso8601String());
        }

        final response = await query as List;

        for (final row in response) {
            await _db.subcategoryDao.saveSubcategory(SubcategoriesCompanion.insert(
                id: row['id'] as String,
                categoryId: row['category_id'] as String,
                name: row['name'] as String,
                updatedAt: Value(DateTime.parse(row['updated_at'] as String).toUtc()),
                isDeleted: Value(row['is_deleted'] as bool? ?? false),
                pendingSync: const Value(false),
            ));
        }

        await _db.syncMetaDao.upsertLastSyncedAt(subcategoriesKey, nowUtc);
    }
    Future<void> pullTransactions() async {
        final lastSync = await _db.syncMetaDao.getLastSyncedAtByTable(transactionsKey);
        final nowUtc = DateTime.now().toUtc();

        var query = _sbdb.from('transactions').select();
        if (lastSync != null) {
            query = query.gte('updated_at', lastSync.toUtc().toIso8601String());
        }

        final response = await query as List;

        for (final row in response) {
            await _db.transactionDao.saveTransaction(TransactionsCompanion.insert(
                id: row['id'] as String,
                accountId: row['account_id'] as String,
                categoryId: row['category_id'] as String,
                subcategoryId: Value(row['subcategory_id'] as String?),
                amount: (row['amount'] as num).toDouble(),
                date: DateTime.parse(row['date'] as String).toUtc(),
                transactionType: row['transaction_type'] as String,
                note: Value(row['note'] as String? ?? ''),
                updatedAt: Value(DateTime.parse(row['updated_at'] as String).toUtc()),
                isDeleted: Value(row['is_deleted'] as bool? ?? false),
                pendingSync: const Value(false)
            ));
        }

        await _db.syncMetaDao.upsertLastSyncedAt(transactionsKey, nowUtc);
    }

    // =============================================================================================
    // Push — Drift → Supabase
    // =============================================================================================

    Future<void> pushPending() async {
        await pushPendingAccounts();
        await pushPendingCategories();
        await pushPendingSubcategories();
        await pushPendingTransactions();
    }
    Future<void> pushPendingAccounts() async {
        final pending = await _db.accountDao.getAllPendingAccounts();
        for (final row in pending) {
            try {
                await _sbdb.from('accounts').upsert({
                    'id': row.id,
                    'name': row.name,
                    'color': row.color,
                    'updated_at': row.updatedAt.toUtc().toIso8601String(),
                    'is_deleted': row.isDeleted
                });
                await _db.accountDao.updateAccountAsSyncedById(row.id);
            } catch (e) {
                print('[SyncService] failed to push account ${row.id}: $e');
            }
        }
    }
    Future<void> pushPendingCategories() async {
        final pending = await _db.categoryDao.getAllPendingCategories();
        for (final row in pending) {
            try {
                await _sbdb.from('categories').upsert({
                    'id': row.id,
                    'name': row.name,
                    'color': row.color,
                    'type': row.type,
                    'updated_at': row.updatedAt.toUtc().toIso8601String(),
                    'is_deleted': row.isDeleted
                });
                await _db.categoryDao.updateCategoryAsSyncedById(row.id);
            } catch (e) {
                print('[SyncService] failed to push category ${row.id}: $e');
            }
        }
    }
    Future<void> pushPendingSubcategories() async {
        final pending = await _db.subcategoryDao.getAllPendingSubcategories();
        for (final row in pending) {
            try {
                await _sbdb.from('subcategories').upsert({
                    'id': row.id,
                    'category_id': row.categoryId,
                    'name': row.name,
                    'updated_at': row.updatedAt.toUtc().toIso8601String(),
                    'is_deleted': row.isDeleted,
                });
                await _db.subcategoryDao.updateSubcategoryAsSyncedById(row.id);
            } catch (e) {
                print('[SyncService] failed to push subcategory ${row.id}: $e');
            }
        }
    }
    Future<void> pushPendingTransactions() async {
        final pending = await _db.transactionDao.getAllPendingTransactions();
        for (final row in pending) {
            try {
                await _sbdb.from('transactions').upsert({
                    'id': row.id,
                    'account_id': row.accountId,
                    'category_id': row.categoryId,
                    'subcategory_id': row.subcategoryId,
                    'amount': row.amount,
                    'date': row.date.toUtc().toIso8601String(),
                    'transaction_type': row.transactionType,
                    'note': row.note,
                    'updated_at': row.updatedAt.toUtc().toIso8601String(),
                    'is_deleted': row.isDeleted
                });
                await _db.transactionDao.updateTransactionAsSyncedById(row.id);
            } catch (e) {
                print('[SyncService] failed to push transaction ${row.id}: $e');
            }
        }
    }
}