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

/// Transaction List (transaction_screen.dart) — full list, all-time, paginated ===================

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
        data: (transactions) => _groupByDate(transactions),
        orElse: () => {},
    );
});

/// Dashboard Transactions (dashboard_screen.dart) — current month only, paginated ================

class DashboardTransactionState {
    final List<Transaction> transactions;
    final bool hasMore;
    final bool isLoadingMore;
    final int page;

    const DashboardTransactionState({
        this.transactions = const [],
        this.hasMore = true,
        this.isLoadingMore = false,
        this.page = 0,
    });

    DashboardTransactionState copyWith({
        List<Transaction>? transactions,
        bool? hasMore,
        bool? isLoadingMore,
        int? page,
    }) => DashboardTransactionState(
        transactions: transactions ?? this.transactions,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        page: page ?? this.page,
    );
}

class DashboardTransactionNotifier
    extends AutoDisposeAsyncNotifier<DashboardTransactionState> {
    static const int _limit = 20;

    @override
    Future<DashboardTransactionState> build() async {
        final now = DateTime.now();
        final service = ref.read(transactionServiceProvider);
        final results = await service.getByYearAndMonth(
            year: now.year,
            month: now.month,
            page: 0,
            limit: _limit,
        );
        return DashboardTransactionState(
            transactions: results,
            hasMore: results.length == _limit,
            page: 0,
        );
    }

    Future<void> fetchMore() async {
        final current = state.valueOrNull;
        if (current == null || !current.hasMore || current.isLoadingMore) return;

        state = AsyncData(current.copyWith(isLoadingMore: true));

        try {
            final now = DateTime.now();
            final nextPage = current.page + 1;
            final service = ref.read(transactionServiceProvider);
            final results = await service.getByYearAndMonth(
                year: now.year,
                month: now.month,
                page: nextPage,
                limit: _limit,
            );
            state = AsyncData(current.copyWith(
                transactions: [...current.transactions, ...results],
                hasMore: results.length == _limit,
                isLoadingMore: false,
                page: nextPage,
            ));
        } catch (e, st) {
            state = AsyncData(current.copyWith(isLoadingMore: false));
        }
    }
}

final dashboardTransactionNotifierProvider = AutoDisposeAsyncNotifierProvider<DashboardTransactionNotifier, DashboardTransactionState>(
    DashboardTransactionNotifier.new,
);

final dashboardTransactionGroupedProvider = Provider.autoDispose<Map<DateTime, List<Transaction>>>((ref) {
    final state = ref.watch(dashboardTransactionNotifierProvider).valueOrNull;
    if (state == null) return {};
    return _groupByDate(state.transactions);
});

/// Shared Helpers ================================================================================

Map<DateTime, List<Transaction>> _groupByDate(List<Transaction> transactions) {
    final Map<DateTime, List<Transaction>> grouped = {};
    for (final trn in transactions) {
        final date = DateTime(trn.date.year, trn.date.month, trn.date.day);
        grouped.putIfAbsent(date, () => []).add(trn);
    }
    return grouped;
}

/// Service Provider ==============================================================================

final transactionServiceProvider = Provider<TransactionService>((ref) {
    return TransactionService();
});

/// Misc FutureProviders ==========================================================================

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