import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction.dart';
import 'transaction_service.dart';

class TransactionFilter {
    final String? accountId;
    final String? categoryId;
    final TransactionType? transactionType;
    final DateTime? startDate;
    final DateTime? endDate;
    final int page;
    final int limit;

    const TransactionFilter({
        this.accountId,
        this.categoryId,
        this.transactionType,
        this.startDate,
        this.endDate,
        this.page = 0,
        this.limit = 20,
    });
}

final transactionServiceProvider = Provider<TransactionService>((ref) {
    return TransactionService();
});

final getAllTransactionByPaginationProvider = FutureProvider.family<List<Transaction>, TransactionFilter>((ref, transactionFilter) async {
    final service = ref.read(transactionServiceProvider);
    return service.getAllbyPagination(
        page: transactionFilter.page,
        limit: transactionFilter.limit,
    );
});

final getAllTransactionGroupedByDateByPaginationProvider = Provider.family<Map<DateTime, List<Transaction>>, TransactionFilter>((ref, transactionFilter) {
    final transactionListByPagination = ref.watch(getAllTransactionByPaginationProvider(transactionFilter));

    return transactionListByPagination.maybeWhen(
        data: (transactions) {
            final Map<DateTime, List<Transaction>> grouped = {};
            for (var trn in transactions) {
                final date = DateTime(trn.date.year, trn.date.month, trn.date.day);
                grouped.putIfAbsent(date, () => []).add(trn);
            }
            return grouped;
        },
        orElse: () => {},
    );
});

final getTransactionBySpecificationProvider = FutureProvider.family<List<Transaction>, TransactionFilter>((ref, transactionFilter) async {
    final service = ref.read(transactionServiceProvider);
    return service.getBySpecification(
        accountId: transactionFilter.accountId,
        categoryId: transactionFilter.categoryId,
        transactionType: transactionFilter.transactionType,
        startDate: transactionFilter.startDate,
        endDate: transactionFilter.endDate,
        page: transactionFilter.page,
        limit: transactionFilter.limit,
    );
});

final getTransactionGroupedByDateBySpecificationProvider = Provider.family<Map<DateTime, List<Transaction>>, TransactionFilter>((ref, transactionFilter) {
    final transactionListBySpecification = ref.watch(getTransactionBySpecificationProvider(transactionFilter));

    return transactionListBySpecification.maybeWhen(
        data: (transactions) {
            final Map<DateTime, List<Transaction>> grouped = {};
            for (var trn in transactions) {
                final date = DateTime(trn.date.year, trn.date.month, trn.date.day);
                grouped.putIfAbsent(date, () => []).add(trn);
            }
            return grouped;
        },
        orElse: () => {},
    );
});

final getTransactionByIdProvider = FutureProvider.family<Transaction, String>((ref, id) async {
    final service = ref.read(transactionServiceProvider);
    return service.getById(id);
});

final getTotalTransactionAmmountByAccountIdProvider = FutureProvider.family<double, String>((ref, accountId) async {
    final service = ref.read(transactionServiceProvider);
    return service.getTransactionAmmountByAccountId(accountId);
});