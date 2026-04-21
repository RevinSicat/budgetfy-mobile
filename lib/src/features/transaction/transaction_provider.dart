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

final getAllbyPaginationProvider = FutureProvider.family<List<Transaction>, TransactionFilter>((ref, transactionFilter) async {
    final service = ref.read(transactionServiceProvider);
    return service.getAllbyPagination(
        page: transactionFilter.page,
        limit: transactionFilter.limit,
    );
});

final getByIdProvider = FutureProvider.family<Transaction, String>((ref, id) async {
    final service = ref.read(transactionServiceProvider);
    return service.getById(id);
});

final getBySpecificationProvider = FutureProvider.family<List<Transaction>, TransactionFilter>((ref, transactionFilter) async {
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

final getTransactionAmmountByAccountIdProvider = FutureProvider.family<double, String>((ref, accountId) async {
    final service = ref.read(transactionServiceProvider);
    return service.getTransactionAmmountByAccountId(accountId);
});