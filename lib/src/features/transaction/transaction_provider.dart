import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/local/local_database_provider.dart';
import '../dashboard/category_chart_data.dart';
import 'transaction.dart';
import 'transaction_service.dart';

final transactionServiceProvider = Provider<TransactionService>((ref) {
    return TransactionService(ref.watch(localDatabaseProvider));
});

// =================================================================================================
// Transaction Screen — paginated, all-time list
// =================================================================================================

class TransactionListNotifier extends AutoDisposeAsyncNotifier<List<Transaction>> {
    int page = 0;
    bool _hasMore = true;
    bool _isFetchingMore = false;
    static const int limit = 20;

    @override
    Future<List<Transaction>> build() async {
        page = 0;
        _hasMore = true;
        _isFetchingMore = false;
        final result = await ref.read(transactionServiceProvider)
            .findAllByPage(
                page: 0, 
                limit: limit
            );
        if (result.length < limit) {
            _hasMore = false;
        }
        return result;
    }

    Future<void> fetchMore() async {
        if (!_hasMore || _isFetchingMore) {
            return;
        }
        final current = state.valueOrNull;

        if (current == null) {
            return;
        }

        _isFetchingMore = true;
        page++;

        try {
            final more = await ref.read(transactionServiceProvider)
                .findAllByPage(
                    page: page, 
                    limit: limit
                );
            if (more.length < limit) {
                _hasMore = false;
            }
            state = AsyncData([
                ...current, 
                ...more
            ]);
        } catch (e, st) {
            page--;
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
    return ref.watch(transactionListNotifierProvider).maybeWhen(
        data: (txns) => groupByDate(txns),
        orElse: () => {},
    );
});

// =================================================================================================
// Dashboard — current-month, paginated
// =================================================================================================

class DashboardTransactionState {
    final List<Transaction> transactions;
    final bool hasMore;
    final bool isLoadingMore;
    final int page;

    const DashboardTransactionState({
        this.transactions = const [],
        this.hasMore = true,
        this.isLoadingMore = false,
        this.page = 0
    });

    DashboardTransactionState copyWith({
        List<Transaction>? transactions,
        bool? hasMore,
        bool? isLoadingMore,
        int? page
    }) => DashboardTransactionState(
        transactions:  transactions  ?? this.transactions,
        hasMore:       hasMore       ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        page:          page          ?? this.page,
    );
}

class DashboardTransactionNotifier extends AutoDisposeAsyncNotifier<DashboardTransactionState> {
    static const int limit = 20;

    @override
    Future<DashboardTransactionState> build() async {
        final now = DateTime.now();
        final results = await ref.read(transactionServiceProvider)
            .findAllByYearAndMonth(
                year: now.year, 
                month: now.month,
                page: 0, 
                limit: limit
            );
        return DashboardTransactionState(
            transactions: results,
            hasMore: results.length == limit
        );
    }

    Future<void> fetchMore() async {
        final current = state.valueOrNull;
        if (current == null || !current.hasMore || current.isLoadingMore) {
            return;
        }

        state = AsyncData(current.copyWith(isLoadingMore: true));

        try {
            final now = DateTime.now();
            final nextPage = current.page + 1;
            final results  = await ref.read(transactionServiceProvider)
                .findAllByYearAndMonth(
                    year: now.year, 
                    month: now.month,
                    page: nextPage, 
                    limit: limit
                );
            state = AsyncData(current.copyWith(
                transactions: [...current.transactions, ...results],
                hasMore: results.length == limit,
                isLoadingMore: false,
                page: nextPage,
            ));
        } catch (e) {
            state = AsyncData(current.copyWith(isLoadingMore: false));
        }
    }
}

final dashboardTransactionNotifierProvider = AutoDisposeAsyncNotifierProvider<DashboardTransactionNotifier, DashboardTransactionState>(
    DashboardTransactionNotifier.new,
);

final dashboardTransactionGroupedProvider = Provider.autoDispose<Map<DateTime, List<Transaction>>>((ref) {
    final s = ref.watch(dashboardTransactionNotifierProvider).valueOrNull;
    if (s == null) return {};
    return groupByDate(s.transactions);
});

// =================================================================================================
// Shared helpers
// =================================================================================================

Map<DateTime, List<Transaction>> groupByDate(List<Transaction> transactions) {
    final Map<DateTime, List<Transaction>> grouped = {};
    for (final trn in transactions) {
        final date = DateTime(trn.date.year, trn.date.month, trn.date.day);
        grouped.putIfAbsent(date, () => []).add(trn);
    }
    return grouped;
}

// =================================================================================================
// Filter parameter objects
// =================================================================================================

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
        this.page  = 0,
        this.limit = 20
    });
}

class MonthYearFilter {
    final int month;
    final int year;
    const MonthYearFilter({
        required this.month, 
        required this.year
    });

    @override
    bool operator ==(Object other) =>
        other is MonthYearFilter && other.month == month && other.year == year;
    @override
    int get hashCode => Object.hash(month, year);
}

class CategoryMonthFilter {
    final String categoryId;
    final int month;
    final int year;
    const CategoryMonthFilter({
        required this.categoryId,
        required this.month,
        required this.year
    });

    @override
    bool operator ==(Object other) =>
        other is CategoryMonthFilter &&
        other.categoryId == categoryId &&
        other.month == month &&
        other.year == year;
    @override
    int get hashCode => Object.hash(categoryId, month, year);
}

// =================================================================================================
// FutureProviders
// =================================================================================================

final getAllTransactionByPaginationProvider = FutureProvider.family<List<Transaction>, TransactionFilter>((ref, filter) async {
    return ref.read(transactionServiceProvider)
        .findAllByPage(
            page: filter.page, 
            limit: filter.limit
        );
});
final getCategoryAmountSumByMonthAndYearProvider = FutureProvider.autoDispose.family<List<CategoryChartData>, MonthYearFilter>((ref, filter) async {
    return ref.read(transactionServiceProvider)
        .getCategoryAmountSumByMonthAndYear(
            month: filter.month, 
            year: filter.year
        );
});
final getTransactionsByCategoryAndMonthProvider = FutureProvider.autoDispose.family<List<Transaction>, CategoryMonthFilter>((ref, filter) async {
    return ref.read(transactionServiceProvider).findByCategoryAndMonth(
        categoryId: filter.categoryId,
        month: filter.month,
        year: filter.year
    );
});
final getTransactionByIdProvider = FutureProvider.family<Transaction, String>((ref, id) async {
    final result = await ref.read(transactionServiceProvider).findById(id);
    if (result == null) throw Exception('Transaction not found: $id');
    return result;
});
final getTotalTransactionAmmountByAccountIdProvider = FutureProvider.family<double, String>((ref, accountId) async {
    return ref.read(transactionServiceProvider)
        .sumAmountByAccountId(accountId);
});
final getTransactionAmmountSumByCategoryIdProvider = FutureProvider.family<double, String>((ref, categoryId) async {
    return ref.read(transactionServiceProvider)
        .sumAmountByCategoryId(categoryId);
});
final getTransactionNetTotalsProvider = FutureProvider.autoDispose<Map<String, double>>((ref) async {
    return ref.read(transactionServiceProvider)
        .getNetTotals();
});