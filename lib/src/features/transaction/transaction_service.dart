import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/local/local_database.dart';
import '../../core/sync/sync_service.dart';
import '../account/account.dart';
import '../category/category.dart';
import '../dashboard/category_chart_data.dart';
import '../subcategory/subcategory.dart';
import 'transaction.dart';

class TransactionService {
    final LocalDatabase _db;
    final SyncService _sync;

    TransactionService(this._db) : _sync = SyncService(_db);

    Future<List<Transaction>> assembleTransactions(List<TransactionData> transactions) async {
        if (transactions.isEmpty) {
            return [];
        }

        final accountIds = transactions
            .map((account) => account.accountId)
            .toSet()
            .toList();
        final categoryIds = transactions
            .map((category) => category.categoryId)
            .toSet()
            .toList();
        final subcategoryIds = transactions
            .map((subcategory) => subcategory.subcategoryId)
            .whereType<String>()
            .toSet()
            .toList();

        final accountRows = await (_db.select(_db.accounts)
            ..where((transaction) => transaction.id.isIn(accountIds))
        ).get();

        final categoryRows = await (_db.select(_db.categories)
            ..where((transaction) => transaction.id.isIn(categoryIds))
        ).get();

        final subcategoryRows = subcategoryIds.isEmpty
            ? <SubcategoryData>[]
            : await (_db.select(_db.subcategories)
                ..where((transaction) => transaction.id.isIn(subcategoryIds))
            ).get();

        final accountMap = {
            for (final account in accountRows) account.id: account
        };
        final categoryMap = {
            for (final category in categoryRows) category.id: category
        };
        final subcategoryMap = {
            for (final subcategory in subcategoryRows) subcategory.id: subcategory
        };

        return transactions.map((row) {
            final accountRow = accountMap[row.accountId];
            final categoryRow = categoryMap[row.categoryId];
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
                    orElse: () => TransactionType.Default
                ),
                note: row.note,
                account: accountRow != null
                    ? Account(
                        id: accountRow.id, 
                        name: accountRow.name, 
                        color: accountRow.color
                    )
                    : null,
                category: categoryRow != null
                    ? Category(
                        id: categoryRow.id,
                        name: categoryRow.name,
                        color: categoryRow.color,
                        type: CategoryType.values.firstWhere(
                            (e) => e.name == categoryRow.type,
                            orElse: () => CategoryType.expense
                        )
                    )
                    : null,
                subcategory: subcategoryRow != null
                    ? Subcategory(
                        id: subcategoryRow.id,
                        categoryId: subcategoryRow.categoryId,
                        name: subcategoryRow.name
                    )
                    : null
            );
        }).toList();
    }

    // =============================================================================================
    // Queries — paginated lists
    // =============================================================================================

    /// [GET]: Retrieve Transactions by pagination (all time)
    Future<List<Transaction>> findAllByPage({ 
            int page = 0, 
            int limit = 20 
    }) async {
        final rows = await _db.transactionDao.getAllTransactionByPagination(
            page: page, 
            limit: limit
        );
        return assembleTransactions(rows);
    }

    /// [GET]: Retrieve Transactions by {year, month} with pagination
    Future<List<Transaction>> findAllByYearAndMonth({ 
            required int year, 
            required int month,
            int page = 0, 
            int limit = 20
    }) async {
        final rows = await _db.transactionDao.getAllTransactionsByYearAndMonthByPagination(
            year: year, 
            month: month,
            page: page, 
            limit: limit
        );
        return assembleTransactions(rows);
    }

    /// [GET]: Retrieve Transactions by {categoryId, month, year}
    Future<List<Transaction>> findByCategoryAndMonth({
            required String categoryId,
            required int month,
            required int year
    }) async {
        final start = DateTime(year, month, 1);
        final end = DateTime(year, month + 1, 1)
            .subtract(const Duration(milliseconds: 1));

        final rows = await (_db.select(_db.transactions)
            ..where((transactionTable) =>
                transactionTable.categoryId.equals(categoryId) &
                transactionTable.isDeleted.equals(false) &
                transactionTable.date.isBiggerOrEqualValue(start) &
                transactionTable.date.isSmallerOrEqualValue(end)
            )
            ..orderBy([(transactionTable) => OrderingTerm.desc(transactionTable.date)])
        ).get();

        return assembleTransactions(rows);
    }

    // =============================================================================================
    // Queries — single record
    // =============================================================================================

    /// [GET]: Retrieve Transaction by {id}
    Future<Transaction?> findById(String id) async {
        final row = await _db.transactionDao.getTransactionById(id);
        if (row == null) {
            return null;
        }

        final assembled = await assembleTransactions([row]);
        return assembled.firstOrNull;
    }

    // =============================================================================================
    // Queries — aggregations
    // =============================================================================================

    /// [GET]: Retrieve Net Income / Expense / Worth totals
    Future<Map<String, double>> getNetTotals() {
        return _db.transactionDao.getTransactionNetTotals();
    }

    /// [GET]: Retrieve Transaction amount sum by {accountId}
    Future<double> sumAmountByAccountId(String accountId) {
        return _db.transactionDao.getTransactionAmountSumByAccountId(accountId);
    }

    /// [GET]: Retrieve Transaction amount sum by {categoryId}
    Future<double> sumAmountByCategoryId(String categoryId) {
        return _db.transactionDao.getTransactionAmountSumByCategoryId(categoryId);
    }

    /// [GET]: Retrieve Transaction count by {accountId}
    Future<int> countByAccountId(String accountId) {
        return _db.transactionDao.getTransactionCountByAccountId(accountId);
    }

    /// [GET]: Retrieve Transaction count by {categoryId}
    Future<int> countByCategoryId(String categoryId) {
        return _db.transactionDao.getTransactionCountByCategoryId(categoryId);
    }

    /// [GET]: Retrieve category amount sums grouped by category for {month, year}
    Future<List<CategoryChartData>> getCategoryAmountSumByMonthAndYear({
            required int month, 
            required int year,
    }) async {
        final start = DateTime(year, month, 1);
        final end = DateTime(year, month + 1, 1)
            .subtract(const Duration(milliseconds: 1));

        final rows = await (_db.select(_db.transactions)
            ..where((transactionTable) =>
                transactionTable.isDeleted.equals(false) &
                transactionTable.date.isBiggerOrEqualValue(start) &
                transactionTable.date.isSmallerOrEqualValue(end)
            )
        ).get();

        if (rows.isEmpty) return [];

        final categoryIds  = rows
            .map((row) => row.categoryId)
            .toSet()
            .toList();
        final categoryRows = await (_db.select(_db.categories)
            ..where((categoryTable) => categoryTable.id.isIn(categoryIds))
        ).get();
        final categoryMap  = {
            for (final category in categoryRows) category.id: category
        };

        final Map<String, double> totals = {};
        for (final row in rows) {
            totals[row.categoryId] = (totals[row.categoryId] ?? 0) + row.amount.abs();
        }

        return totals.entries.map((entry) {
            final cat = categoryMap[entry.key];
            if (cat == null) return null;
            return CategoryChartData(
                categoryId: cat.id,
                name: cat.name,
                color: cat.color,
                type: CategoryType.values.firstWhere(
                    (categoryType) => categoryType.name == cat.type,
                    orElse: () => CategoryType.expense
                ),
                total: entry.value
            );
        }).whereType<CategoryChartData>().toList();
    }

    // =============================================================================================
    // Commands
    // =============================================================================================

    /// [POST]: Create Transaction
    Future<void> save(Transaction transaction) async {
        final id = transaction.id.isEmpty ? const Uuid().v4() : transaction.id;

        await _db.transactionDao.saveTransaction(TransactionsCompanion(
            id: Value(id),
            accountId: Value(transaction.accountId),
            categoryId: Value(transaction.categoryId),
            subcategoryId: Value(transaction.subcategoryId),
            amount: Value(transaction.amount),
            date: Value(transaction.date),
            transactionType: Value(transaction.transactionType.name),
            note: Value(transaction.note),
            updatedAt: Value(DateTime.now().toUtc()),
            pendingSync: const Value(true)
        ));

        await _sync.pushRecordNow();
    }

    /// [PUT]: Update Transaction
    Future<void> update(Transaction transaction) async {
        await _db.transactionDao.updateTransaction(TransactionsCompanion(
            id: Value(transaction.id),
            accountId: Value(transaction.accountId),
            categoryId: Value(transaction.categoryId),
            subcategoryId: Value(transaction.subcategoryId),
            amount: Value(transaction.amount),
            date: Value(transaction.date),
            transactionType: Value(transaction.transactionType.name),
            note: Value(transaction.note),
            updatedAt: Value(DateTime.now().toUtc()),
            pendingSync: const Value(true)
        ));

        await _sync.pushRecordNow();
    }

    /// [PUT]: Invert transaction amounts for all transactions in {categoryId}.
    /// Called when a category's type changes (income ↔ expense).
    Future<void> updateAmountByCategory(String categoryId) async {
        final rows = await (_db.select(_db.transactions)
            ..where((transactionTable) =>
                transactionTable.categoryId.equals(categoryId) &
                transactionTable.isDeleted.equals(false)
            )
        ).get();

        for (final row in rows) {
            await _db.transactionDao.updateTransaction(TransactionsCompanion(
                id: Value(row.id),
                amount: Value(row.amount * -1),
                updatedAt: Value(DateTime.now().toUtc()),
                pendingSync: const Value(true)
            ));
        }
        // No pushRecordNow here — CategoryService.update() calls it after this returns.
    }

    /// [DELETE]: Soft-delete Transaction by {id}
    Future<void> deleteById(String id) async {
        await _db.transactionDao.softDeleteTransactionById(id);
        await _sync.pushRecordNow();
    }
}