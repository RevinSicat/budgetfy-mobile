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

class TransactionListNotifier extends AutoDisposeAsyncNotifier<List<Transaction>> {
    int _page = 0;
    bool _hasMore = true;
    bool _isFetchingMore = false;
    static const int _limit = 20;

    @override
    Future<List<Transaction>> build() async {
        _page = 0;
        _hasMore = true;
        _isFetchingMore = false;
        final service = ref.read(transactionServiceProvider);
        final result = await service.getAllbyPagination(page: 0, limit: _limit);
        if (result.length < _limit) _hasMore = false;
        return result;
    }

    Future<void> fetchMore() async {
        if (!_hasMore || _isFetchingMore) return;
        final current = state.valueOrNull;
        if (current == null) return;

        _isFetchingMore = true;
        _page++;

        try {
            final service = ref.read(transactionServiceProvider);
            final more = await service.getAllbyPagination(page: _page, limit: _limit);
            if (more.length < _limit) _hasMore = false;
            state = AsyncData([...current, ...more]);
        } catch (e, st) {
            _page--;
            state = AsyncError(e, st);
        } finally {
            _isFetchingMore = false;
        }
    }

    bool get hasMore => _hasMore;
    bool get isFetchingMore => _isFetchingMore;
}

final transactionListNotifierProvider = AutoDisposeAsyncNotifierProvider<TransactionListNotifier, List<Transaction>>(
    TransactionListNotifier.new,
);

final transactionListGroupedProvider = Provider.autoDispose<Map<DateTime, List<Transaction>>>((ref) {
    final transactionList = ref.watch(transactionListNotifierProvider);
    return transactionList.maybeWhen(
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

final dashboardRecentTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
    final service = ref.read(transactionServiceProvider);
    return service.getAllbyPagination(page: 0, limit: 20);
});

final dashboardRecentTransactionsGroupedProvider = Provider<Map<DateTime, List<Transaction>>>((ref) {
    final transactionList = ref.watch(dashboardRecentTransactionsProvider);
    return transactionList.maybeWhen(
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

final transactionServiceProvider = Provider<TransactionService>((ref) {
    return TransactionService();
});

final getAllTransactionByPaginationProvider = FutureProvider.family<List<Transaction>, TransactionFilter>((ref, filter) async {
    final service = ref.read(transactionServiceProvider);
    return service.getAllbyPagination(page: filter.page, limit: filter.limit);
});

final getTransactionBySpecificationProvider = FutureProvider.family<List<Transaction>, TransactionFilter>((ref, filter) async {
    final service = ref.read(transactionServiceProvider);
    return service.getBySpecification(
        accountId: filter.accountId,
        categoryId: filter.categoryId,
        transactionType: filter.transactionType,
        startDate: filter.startDate,
        endDate: filter.endDate,
        page: filter.page,
        limit: filter.limit,
    );
});

final getTransactionByIdProvider =
    FutureProvider.family<Transaction, String>((ref, id) async {
        final service = ref.read(transactionServiceProvider);
        return service.getById(id);
    });

final getTransactionAmountSumProvider = FutureProvider<double>((ref) async {
    final service = ref.read(transactionServiceProvider);
    return service.getTransactionAmmountSum();
});

final getTotalTransactionAmmountByAccountIdProvider = FutureProvider.family<double, String>((ref, accountId) async {
    final service = ref.read(transactionServiceProvider);
    return service.getTransactionAmmountSumByAccountId(accountId);
});

final getTransactionAmmountSumByCategoryIdProvider = FutureProvider.family<double, String>((ref, categoryId) async {
    final service = ref.read(transactionServiceProvider);
    return service.getTransactionAmmountSumByCategoryId(categoryId);
});