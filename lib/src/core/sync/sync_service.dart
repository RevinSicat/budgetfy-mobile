import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../local/local_database.dart';

class SyncService {
    final LocalDatabase _db;
    final SupabaseClient _sbdb;

    SyncService(this._db) : _sbdb = Supabase.instance.client;

    // Table key constants — used in SyncMeta to track per-table sync timestamps
    static const String _accountsKey     = 'accounts';
    static const String _categoriesKey   = 'categories';
    static const String _subcategoriesKey = 'subcategories';
    static const String _transactionsKey = 'transactions';

    // =============================================================================================
    // Public API
    // =============================================================================================

    /// Full sync — call on app open and on manual "Sync Now"
    /// Runs pull for all tables sequentially, order matters:
    /// accounts and categories must exist before transactions are pulled
    Future<void> syncAll() async {
        try {
            await _pullAccounts();
            await _pullCategories();
            await _pullSubcategories();
            await _pullTransactions();
            await _pushPending();
        } catch (e) {
            print('[SyncService.syncAll error]: $e');
            rethrow;
        }
    }

    /// Only push pending local changes to Supabase — used after writes when online
    Future<void> pushPending() async {
        try {
            await _pushPending();
        } catch (e) {
            print('[SyncService.pushPending error]: $e');
            rethrow;
        }
    }

    // =============================================================================================
    // Pull — Supabase → Drift
    // =============================================================================================

    Future<void> _pullAccounts() async {
        final lastSync = await _db.syncMetaDao.getLastSyncedAtByTable(_accountsKey);
        final now = DateTime.now();

        var query = _sbdb.from('accounts').select();
        if (lastSync != null) {
            query = query.gte('updated_at', lastSync.toIso8601String());
        }

        final response = await query;
        for (final row in response as List) {
            await _db.accountDao.saveAccount(AccountsCompanion.insert(
                id: row['id'] as String,
                name: row['name'] as String,
                color: row['color'] as String,
                updatedAt: Value(DateTime.parse(row['updated_at'] as String)),
                isDeleted: Value(row['is_deleted'] as bool? ?? false),
                pendingSync: const Value(false), // came from Supabase, already synced
            ));
        }

        await _db.syncMetaDao.upsertLastSyncedAt(_accountsKey, now);
    }

    Future<void> _pullCategories() async {
        final lastSync = await _db.syncMetaDao.getLastSyncedAtByTable(_categoriesKey);
        final now = DateTime.now();

        var query = _sbdb.from('categories').select();
        if (lastSync != null) {
            query = query.gte('updated_at', lastSync.toIso8601String());
        }

        final response = await query;
        for (final row in response as List) {
            await _db.categoryDao.saveCategory(CategoriesCompanion.insert(
                id: row['id'] as String,
                name: row['name'] as String,
                color: row['color'] as String,
                type: row['type'] as String,
                updatedAt: Value(DateTime.parse(row['updated_at'] as String)),
                isDeleted: Value(row['is_deleted'] as bool? ?? false),
                pendingSync: const Value(false),
            ));
        }

        await _db.syncMetaDao.upsertLastSyncedAt(_categoriesKey, now);
    }

    Future<void> _pullSubcategories() async {
        final lastSync = await _db.syncMetaDao.getLastSyncedAtByTable(_subcategoriesKey);
        final now = DateTime.now();

        var query = _sbdb.from('subcategories').select();
        if (lastSync != null) {
            query = query.gte('updated_at', lastSync.toIso8601String());
        }

        final response = await query;
        for (final row in response as List) {
            await _db.subcategoryDao.saveSubcategory(SubcategoriesCompanion.insert(
                id: row['id'] as String,
                categoryId: row['category_id'] as String,
                name: row['name'] as String,
                updatedAt: Value(DateTime.parse(row['updated_at'] as String)),
                isDeleted: Value(row['is_deleted'] as bool? ?? false),
                pendingSync: const Value(false),
            ));
        }

        await _db.syncMetaDao.upsertLastSyncedAt(_subcategoriesKey, now);
    }

    Future<void> _pullTransactions() async {
        final lastSync = await _db.syncMetaDao.getLastSyncedAtByTable(_transactionsKey);
        final now = DateTime.now();

        var query = _sbdb.from('transactions').select();
        if (lastSync != null) {
            query = query.gte('updated_at', lastSync.toIso8601String());
        }

        final response = await query;
        for (final row in response as List) {
            await _db.transactionDao.saveTransaction(TransactionsCompanion.insert(
                id: row['id'] as String,
                accountId: row['account_id'] as String,
                categoryId: row['category_id'] as String,
                subcategoryId: Value(row['subcategory_id'] as String?),
                amount: (row['amount'] as num).toDouble(),
                date: DateTime.parse(row['date'] as String),
                transactionType: row['transaction_type'] as String,
                note: Value(row['note'] as String? ?? ''),
                updatedAt: Value(DateTime.parse(row['updated_at'] as String)),
                isDeleted: Value(row['is_deleted'] as bool? ?? false),
                pendingSync: const Value(false),
            ));
        }

        await _db.syncMetaDao.upsertLastSyncedAt(_transactionsKey, now);
    }

    // =============================================================================================
    // Push — Drift → Supabase
    // =============================================================================================

    Future<void> _pushPending() async {
        await _pushPendingAccounts();
        await _pushPendingCategories();
        await _pushPendingSubcategories();
        await _pushPendingTransactions();
    }

    Future<void> _pushPendingAccounts() async {
        final pending = await _db.accountDao.getAllPendingAccounts();
        for (final row in pending) {
            try {
                await _sbdb.from('accounts').upsert({
                    'id':         row.id,
                    'name':       row.name,
                    'color':      row.color,
                    'updated_at': row.updatedAt.toIso8601String(),
                    'is_deleted': row.isDeleted,
                });
                await _db.accountDao.updateAccountAsSyncedById(row.id);
            } catch (e) {
                print('[SyncService] failed to push account ${row.id}: $e');
                // continue pushing others even if one fails
            }
        }
    }

    Future<void> _pushPendingCategories() async {
        final pending = await _db.categoryDao.getAllPendingCategories();
        for (final row in pending) {
            try {
                await _sbdb.from('categories').upsert({
                    'id':         row.id,
                    'name':       row.name,
                    'color':      row.color,
                    'type':       row.type,
                    'updated_at': row.updatedAt.toIso8601String(),
                    'is_deleted': row.isDeleted,
                });
                await _db.categoryDao.updateCategoryAsSyncedById(row.id);
            } catch (e) {
                print('[SyncService] failed to push category ${row.id}: $e');
            }
        }
    }

    Future<void> _pushPendingSubcategories() async {
        final pending = await _db.subcategoryDao.getAllPendingSubcategories();
        for (final row in pending) {
            try {
                await _sbdb.from('subcategories').upsert({
                    'id':          row.id,
                    'category_id': row.categoryId,
                    'name':        row.name,
                    'updated_at':  row.updatedAt.toIso8601String(),
                    'is_deleted':  row.isDeleted,
                });
                await _db.subcategoryDao.updateSubcategoryAsSyncedById(row.id);
            } catch (e) {
                print('[SyncService] failed to push subcategory ${row.id}: $e');
            }
        }
    }

    Future<void> _pushPendingTransactions() async {
        final pending = await _db.transactionDao.getAllPendingTransactions();
        for (final row in pending) {
            try {
                await _sbdb.from('transactions').upsert({
                    'id':               row.id,
                    'account_id':       row.accountId,
                    'category_id':      row.categoryId,
                    'subcategory_id':   row.subcategoryId,
                    'amount':           row.amount,
                    'date':             row.date.toIso8601String(),
                    'transaction_type': row.transactionType,
                    'note':             row.note,
                    'updated_at':       row.updatedAt.toIso8601String(),
                    'is_deleted':       row.isDeleted,
                });
                await _db.transactionDao.updateTransactionAsSyncedById(row.id);
            } catch (e) {
                print('[SyncService] failed to push transaction ${row.id}: $e');
            }
        }
    }
}