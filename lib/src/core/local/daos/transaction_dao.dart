import 'package:drift/drift.dart';
import '../local_database.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionDao extends DatabaseAccessor<LocalDatabase> with _$TransactionDaoMixin {
    TransactionDao(super.db);

    /// [GET]: Retrieve Transaction list by pagination
    Future<List<TransactionData>> getAllTransactionByPagination({
        int page = 0, int limit = 20,
    }) {
        return (
            select(transactions)
                ..where((t) => t.isDeleted.equals(false))
                ..orderBy([(t) => OrderingTerm.desc(t.date)])
                ..limit(limit, offset: page * limit)
        ).get();
    }

    /// [GET]: Retrieve Transaction list by {year, month} with pagination
    Future<List<TransactionData>> getAllTransactionsByYearAndMonthByPagination({
        required int year, required int month,
        int page = 0, int limit = 20,
    }) {
        final start = DateTime(year, month, 1);
        final end   = DateTime(year, month + 1, 1)
            .subtract(const Duration(milliseconds: 1));
        return (
            select(transactions)
                ..where((t) =>
                    t.isDeleted.equals(false) &
                    t.date.isBiggerOrEqualValue(start) &
                    t.date.isSmallerOrEqualValue(end)
                )
                ..orderBy([(t) => OrderingTerm.desc(t.date)])
                ..limit(limit, offset: page * limit)
        ).get();
    }

    /// [GET]: Retrieve Transaction by {id}
    Future<TransactionData?> getTransactionById(String id) {
        return (
            select(transactions)
                ..where((t) => t.id.equals(id))
        ).getSingleOrNull();
    }

    /// [GET]: Retrieve all Transactions pending sync to Supabase
    Future<List<TransactionData>> getAllPendingTransactions() {
        return (
            select(transactions)
                ..where((t) => t.pendingSync.equals(true))
        ).get();
    }

    /// [GET]: Retrieve all non-deleted Transactions by {categoryId}
    /// Used internally when inverting amounts on category type change
    Future<List<TransactionData>> getAllTransactionsByCategoryId(String categoryId) {
        return (
            select(transactions)
                ..where((t) =>
                    t.categoryId.equals(categoryId) &
                    t.isDeleted.equals(false)
                )
        ).get();
    }

    /// [POST]: Create Transaction
    Future<void> saveTransaction(TransactionsCompanion entry) {
        return into(transactions).insertOnConflictUpdate(entry);
    }

    /// [PUT]: Update Transaction
    Future<void> updateTransaction(TransactionsCompanion entry) {
        return (
            update(transactions)
                ..where((t) => t.id.equals(entry.id.value))
        ).write(entry);
    }

    /// [PUT]: Mark Transaction as synced by {id}
    Future<void> updateTransactionAsSyncedById(String id) {
        return (
            update(transactions)
                ..where((t) => t.id.equals(id))
        ).write(const TransactionsCompanion(
            pendingSync: Value(false),
        ));
    }

    /// [DELETE]: Mark Transaction as deleted by {id}
    Future<void> softDeleteTransactionById(String id) {
        return (
            update(transactions)
                ..where((t) => t.id.equals(id))
        ).write(TransactionsCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(DateTime.now()),
            pendingSync: const Value(true),
        ));
    }

    // =============================================================================================
    // Computation Queries
    // =============================================================================================

    /// [GET]: Retrieve Net Income, Expense, Worth
    Future<Map<String, double>> getTransactionNetTotals() async {
        final rows = await (
            select(transactions)
                ..where((t) => t.isDeleted.equals(false))
        ).get();

        double netIncome  = 0;
        double netExpense = 0;

        for (final row in rows) {
            if (row.amount >= 0) {
                netIncome  += row.amount;
            } else {
                netExpense += row.amount.abs();
            }
        }

        return {
            'net_worth':  double.parse((netIncome - netExpense).toStringAsFixed(2)),
            'net_income': double.parse(netIncome.toStringAsFixed(2)),
            'net_expense':double.parse(netExpense.toStringAsFixed(2)),
        };
    }

    /// [GET]: Retrieve Transaction Amount Sum by {accountId}
    Future<double> getTransactionAmountSumByAccountId(String accountId) async {
        final amountSum = transactions.amount.sum();
        final query = selectOnly(transactions)
            ..addColumns([amountSum])
            ..where(
                transactions.accountId.equals(accountId) &
                transactions.isDeleted.equals(false),
            );
        final result = await query.getSingle();
        return result.read(amountSum) ?? 0.0;
    }

    /// [GET]: Retrieve Transaction Amount Sum by {categoryId}
    Future<double> getTransactionAmountSumByCategoryId(String categoryId) async {
        final amountSum = transactions.amount.sum();
        final query = selectOnly(transactions)
            ..addColumns([amountSum])
            ..where(
                transactions.categoryId.equals(categoryId) &
                transactions.isDeleted.equals(false),
            );
        final result = await query.getSingle();
        return result.read(amountSum) ?? 0.0;
    }

    /// [GET]: Retrieve Transaction Count by {accountId}
    Future<int> getTransactionCountByAccountId(String accountId) async {
        final count = countAll(
            filter: transactions.accountId.equals(accountId) &
                transactions.isDeleted.equals(false),
        );
        final query = selectOnly(transactions)..addColumns([count]);
        final result = await query.getSingle();
        return result.read(count) ?? 0;
    }

    /// [GET]: Retrieve Transaction Count by {categoryId}
    Future<int> getTransactionCountByCategoryId(String categoryId) async {
        final count = countAll(
            filter: transactions.categoryId.equals(categoryId) &
                transactions.isDeleted.equals(false),
        );
        final query = selectOnly(transactions)..addColumns([count]);
        final result = await query.getSingle();
        return result.read(count) ?? 0;
    }
}