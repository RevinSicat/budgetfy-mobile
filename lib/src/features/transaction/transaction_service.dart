import 'package:budgetfy/src/features/category/category.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/local/local_database.dart';
import '../../core/sync/sync_service.dart';
import '../account/account.dart';
import '../dashboard/category_chart_data.dart';
import '../subcategory/subcategory.dart';
import 'transaction.dart';


class TransactionService {
    final LocalDatabase _db;
    final SyncService _syncService;

    TransactionService(this._db) : _syncService = SyncService(_db);

    // =============================================================================================
    // Private Helpers — Option A join assembly
    // =============================================================================================

    /// Fetches related Account, Category, Subcategory rows by their IDs and
    /// assembles them into [Transaction] domain objects.
    Future<List<Transaction>> _assembleTransactions(
        List<TransactionData> rows,
    ) async {
        if (rows.isEmpty) return [];

        // Collect unique IDs from the page
        final accountIds     = rows.map((r) => r.accountId).toSet().toList();
        final categoryIds    = rows.map((r) => r.categoryId).toSet().toList();
        final subcategoryIds = rows
            .map((r) => r.subcategoryId)
            .whereType<String>()
            .toSet()
            .toList();

        // Batch fetch related rows — 3 small local queries
        final accountRows = await (_db.select(_db.accounts)
            ..where((t) => t.id.isIn(accountIds))
        ).get();

        final categoryRows = await (_db.select(_db.categories)
            ..where((t) => t.id.isIn(categoryIds))
        ).get();

        final subcategoryRows = subcategoryIds.isEmpty
            ? <SubcategoryData>[]
            : await (_db.select(_db.subcategories)
                ..where((t) => t.id.isIn(subcategoryIds))
            ).get();

        // Build lookup maps for O(1) access
        final accountMap     = {for (final a in accountRows) a.id: a};
        final categoryMap    = {for (final c in categoryRows) c.id: c};
        final subcategoryMap = {for (final s in subcategoryRows) s.id: s};

        // Assemble domain objects
        return rows.map((row) {
            final accountRow     = accountMap[row.accountId];
            final categoryRow    = categoryMap[row.categoryId];
            final subcategoryRow = row.subcategoryId != null
                ? subcategoryMap[row.subcategoryId]
                : null;

            return Transaction(
                id: row.id,
                accountId: row.accountId,
                categoryId: row.categoryId,
                subcategoryId: row.subcategoryId,
                amount: row.amount,
                date: row.date,
                transactionType: TransactionType.values.firstWhere(
                    (e) => e.name == row.transactionType,
                    orElse: () => TransactionType.Default,
                ),
                note: row.note,
                account: accountRow != null
                    ? Account(
                        id: accountRow.id,
                        name: accountRow.name,
                        color: accountRow.color,
                    )
                    : null,
                category: categoryRow != null
                    ? Category(
                        id: categoryRow.id,
                        name: categoryRow.name,
                        color: categoryRow.color,
                        type: CategoryType.values.firstWhere(
                            (e) => e.name == categoryRow.type,
                            orElse: () => CategoryType.expense,
                        ),
                    )
                    : null,
                subcategory: subcategoryRow != null
                    ? Subcategory(
                        id: subcategoryRow.id,
                        categoryId: subcategoryRow.categoryId,
                        name: subcategoryRow.name,
                    )
                    : null,
            );
        }).toList();
    }

    // =============================================================================================
    // Transaction List
    // =============================================================================================

    /// [GET]: Retreives Transaction List by pagination
    Future<List<Transaction>> getAllbyPagination({
        int page = 0, int limit = 20
    }) async {
        final rows = await _db.transactionDao.getAllTransactionByPagination(
            page: page, limit: limit,
        );
        return _assembleTransactions(rows);
    }

    /// [GET]: Retrieve Transactions by {year, month} with pagination
    Future<List<Transaction>> getByYearAndMonth({
        required int year, required int month,
        int page = 0, int limit = 20,
    }) async {
        final rows = await _db.transactionDao.getAllTransactionsByYearAndMonthByPagination(
            year: year, month: month,
            page: page, limit: limit,
        );
        return _assembleTransactions(rows);
    }

    /// [GET]: Retrieve Transactions by {categoryId, month, year}
    Future<List<Transaction>> getByCategoryAndMonth({
        required String categoryId, 
        required int month,
        required int year,
    }) async {
        final start = DateTime(year, month, 1);
        final end   = DateTime(year, month + 1, 1)
            .subtract(const Duration(milliseconds: 1));

        final rows = await (_db.select(_db.transactions)
            ..where((t) =>
                t.categoryId.equals(categoryId) &
                t.isDeleted.equals(false) &
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerOrEqualValue(end)
            )
            ..orderBy([(t) => OrderingTerm.desc(t.date)])
        ).get();

        return _assembleTransactions(rows);
    }

    // =============================================================================================
    // Transaction
    // =============================================================================================

    /// [GET]: Retreive Transaction by {id}
    Future<Transaction?> getById(String id) async {
        final row = await _db.transactionDao.getTransactionById(id);
        if (row == null) return null;
        final assembled = await _assembleTransactions([row]);
        return assembled.firstOrNull;
    }

    // =============================================================================================
    // Computations
    // =============================================================================================

    /// [GET]: Retreive Net Totals
    Future<Map<String, double>> getNetTotals() {
        return _db.transactionDao.getTransactionNetTotals();
    }

    /// [GET]: Retreive Transaction Amount Sum by {accountId}
    Future<double> getAmountSumByAccountId(String accountId) {
        return _db.transactionDao.getTransactionAmountSumByAccountId(accountId);
    }

    /// [GET]: Retreive Transaction Amount Sum by {categoryId}
    Future<double> getAmountSumByCategoryId(String categoryId) {
        return _db.transactionDao.getTransactionAmountSumByCategoryId(categoryId);
    }

    /// [GET]: Retreive Transaction Count by {accountId}
    Future<int> getCountByAccountId(String accountId) {
        return _db.transactionDao.getTransactionCountByAccountId(accountId);
    }

    /// [GET]: Retreive Transaction Count by {categoryId}
    Future<int> getCountByCategoryId(String categoryId) {
        return _db.transactionDao.getTransactionCountByCategoryId(categoryId);
    }

    /// [GET]: Retreive Transaction Category Amount Sum by {month, year}
    Future<List<CategoryChartData>> getCategoryAmountSumByMonthAndYear({
        required int month, required int year,
    }) async {
        final start = DateTime(year, month, 1);
        final end   = DateTime(year, month + 1, 1)
            .subtract(const Duration(milliseconds: 1));

        final rows = await (_db.select(_db.transactions)
            ..where((t) =>
                t.isDeleted.equals(false) &
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerOrEqualValue(end)
            )
        ).get();

        if (rows.isEmpty) return [];

        final categoryIds = rows.map((r) => r.categoryId).toSet().toList();
        final categoryRows = await (_db.select(_db.categories)
            ..where((t) => t.id.isIn(categoryIds))
        ).get();
        final categoryMap = {for (final c in categoryRows) c.id: c};

        final Map<String, double> totals = {};
        for (final row in rows) {
            totals[row.categoryId] =
                (totals[row.categoryId] ?? 0) + row.amount.abs();
        }

        return totals.entries.map((entry) {
            final cat = categoryMap[entry.key];
            if (cat == null) return null;
            return CategoryChartData(
                categoryId: cat.id,
                name: cat.name,
                color: cat.color,
                type: CategoryType.values.firstWhere(
                    (e) => e.name == cat.type,
                    orElse: () => CategoryType.expense,
                ),
                total: entry.value,
            );
        }).whereType<CategoryChartData>().toList();
    }

    // =============================================================================================
    // Create, Update, Delete
    // =============================================================================================

    /// [POST]: Create Transaction
    Future<void> save(Transaction transaction) async {
        final transactionId = transaction.id.isEmpty
            ? const Uuid().v4()
            : transaction.id;
        final updatedAt = DateTime.now(); // single source of truth

        await _db.transactionDao.saveTransaction(TransactionsCompanion(
            id: Value(transactionId),
            accountId: Value(transaction.accountId),
            categoryId: Value(transaction.categoryId),
            subcategoryId: Value(transaction.subcategoryId),
            amount: Value(transaction.amount),
            date: Value(transaction.date),
            transactionType: Value(transaction.transactionType.name),
            note: Value(transaction.note),
            updatedAt: Value(updatedAt),
            pendingSync: const Value(true),
        ));

        await _syncService.writeToOutbox(
            tableName: 'transactions',
            recordId:  transactionId,
            operation: 'create',
            payload:   {
                'id': transactionId,
                'account_id': transaction.accountId,
                'category_id': transaction.categoryId,
                'subcategory_id': transaction.subcategoryId,
                'amount': transaction.amount,
                'date': transaction.date.toIso8601String(),
                'transaction_type': transaction.transactionType.name,
                'note': transaction.note,
                'is_deleted': false,
                'updated_at': updatedAt.toIso8601String()
            }
        );
    }

    /// [PUT]: Update Transaction
    Future<void> update(Transaction transaction) async {
        final updatedAt = DateTime.now();
        
        await _db.transactionDao.updateTransaction(TransactionsCompanion(
            id: Value(transaction.id),
            accountId: Value(transaction.accountId),
            categoryId: Value(transaction.categoryId),
            subcategoryId: Value(transaction.subcategoryId),
            amount: Value(transaction.amount),
            date: Value(transaction.date),
            transactionType: Value(transaction.transactionType.name),
            note: Value(transaction.note),
            updatedAt: Value(updatedAt),
            pendingSync: const Value(true),
        ));

        await _syncService.writeToOutbox(
            tableName: 'transactions',
            recordId:  transaction.id,
            operation: 'update',
            payload:   transaction.toJson()..['updated_at'] = updatedAt.toIso8601String(),
        );
    }

    /// [PUT]: Update Transaction Amount by {categoryId}
    /// Called when a category type changes (income ↔ expense) — inverts amounts
    Future<void> updateAmountByCategory(String categoryId) async {
        final rows = await (_db.select(_db.transactions)
            ..where((t) =>
                t.categoryId.equals(categoryId) &
                t.isDeleted.equals(false)
            )
        ).get();

        for (final row in rows) {
            final updatedAt = DateTime.now();

            await _db.transactionDao.updateTransaction(TransactionsCompanion(
                id:          Value(row.id),
                amount:      Value(row.amount * -1),
                updatedAt:   Value(updatedAt),
                pendingSync: const Value(true),
            ));

            // Each inverted transaction needs its own outbox entry
            await _syncService.writeToOutbox(
                tableName: 'transactions',
                recordId:  row.id,
                operation: 'update',
                payload: {
                    'id':               row.id,
                    'account_id':       row.accountId,
                    'category_id':      row.categoryId,
                    'subcategory_id':   row.subcategoryId,
                    'amount':           row.amount * -1,
                    'date':             row.date.toIso8601String(),
                    'transaction_type': row.transactionType,
                    'note':             row.note,
                    'is_deleted':       row.isDeleted,
                    'updated_at':       updatedAt.toIso8601String()
                }
            );
        }
    }

    /// [DELETE]: Soft delete Transaction by {id}
    Future<void> deleteById(String id) async {
        await _db.transactionDao.softDeleteTransactionById(id);

        await _syncService.writeToOutbox(
            tableName: 'transactions',
            recordId:  id,
            operation: 'delete',
            payload:   {'id': id, 'updated_at': DateTime.now().toIso8601String()},
        );
    }
}