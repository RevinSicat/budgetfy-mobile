import 'package:budgetfy/src/pages/dashboard/widgets/category_donut_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/account/account_provider.dart';
import '../../features/transaction/transaction_provider.dart';
import '../../common/widgets/cards/account_card.dart';
import '../../common/widgets/tiles/transaction_tile_group_section.dart';
import 'widgets/greeting_header.dart';
import '../../common/widgets/cards/add_account_card.dart';
import '../../common/widgets/forms/transaction_form.dart';
import 'widgets/net_totals_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
    const DashboardScreen({super.key});

    @override
    ConsumerState<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends ConsumerState<DashboardScreen> {
    final ScrollController scrollController = ScrollController();

    @override
    void initState() {
        super.initState();
        scrollController.addListener(_onScroll);
    }

    @override
    void dispose() {
        scrollController.dispose();
        super.dispose();
    }

    void _onScroll() {
        final position = scrollController.position;
        final isNearBottom = position.pixels >= position.maxScrollExtent - 300;
        if (isNearBottom) {
            ref.read(dashboardTransactionNotifierProvider.notifier).fetchMore();
        }
    }

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);
        final accountList = ref.watch(getAllAccountListProvider);
        final transactionList = ref.watch(dashboardTransactionNotifierProvider);
        final transactionListGrouped = ref.watch(dashboardTransactionGroupedProvider);
        final notifier = ref.read(dashboardTransactionNotifierProvider.notifier);

        return Scaffold(
            body: SafeArea(
                child: RefreshIndicator(
                    onRefresh: () async {
                        ref.invalidate(dashboardTransactionNotifierProvider);
                        ref.invalidate(getAllAccountListProvider);
                        ref.invalidate(getTransactionNetTotalsProvider);
                        ref.invalidate(getCategoryAmountSumByMonthAndYearProvider);
                    },
                    child: SingleChildScrollView(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                // [Greeting Header]: =============================================
                                const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: GreetingHeader()
                                ),

                                // [Accounts Header]: =============================================
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                        'Accounts',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold
                                        )
                                    )
                                ),

                                // [Account Card List]: ===========================================
                                const SizedBox(height: 8),
                                SizedBox(
                                    height: 120,
                                    child: accountList.when(
                                        data: (accounts) => ListView(
                                            scrollDirection: Axis.horizontal,
                                            padding: const EdgeInsets.only(left: 16),
                                            children: [
                                                ...accounts.map((acc) => AccountCard(account: acc)),
                                                const AddAccountCard()
                                            ]
                                        ),
                                        loading: () => const Center(child: CircularProgressIndicator()),
                                        error: (e, _) => Center(child: Text('Error: $e'))
                                    )
                                ),
                                // [Transactions Header]: =========================================
                                const SizedBox(height: 24),
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                        'Transactions',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                        )
                                    )
                                ),

                                // [Transaction Tile List]: =======================================
                                const SizedBox(height: 8),
                                transactionList.when(
                                    loading: () => const Center(child: CircularProgressIndicator()),
                                    error: (e, _) => Center(child: Text('Error: $e')),
                                    data: (_) {
                                        if (transactionListGrouped.isEmpty) {
                                            return const Padding(
                                                padding: EdgeInsets.all(32),
                                                child: Center(child: Text('No Transactions Found')),
                                            );
                                        }
                                        return Column(
                                            children: transactionListGrouped.entries.map((entry) {
                                                return TransactionGroupSection(
                                                    date: entry.key,
                                                    transactions: entry.value,
                                                );
                                            }).toList()
                                        );
                                    }
                                ),

                                // [Footer] =======================================================
                                if (transactionList.hasValue)
                                    transactionList.value!.isLoadingMore
                                        ? const Padding(
                                            padding: EdgeInsets.all(16),
                                            child: Center(child: CircularProgressIndicator())
                                        )
                                        : !transactionList.value!.hasMore
                                            ? const Padding(
                                                padding: EdgeInsets.all(16),
                                                child: Center(
                                                    child: Text(
                                                        'No more transactions this month',
                                                        style: TextStyle(color: Colors.grey)
                                                    )
                                                )
                                            )
                                            : const SizedBox.shrink(),
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Divider(
                                        height: 24,
                                        thickness: 1,
                                        color: theme.dividerColor.withOpacity(0.2)
                                    )
                                ),
                                /// [Net Totals Header]: ==========================================
                                const SizedBox(height: 12),
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                        'Net Totals',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                        )
                                    )
                                ),
                                /// [Net Totals Cards]: ===========================================
                                const SizedBox(height: 12),
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: const NetTotalsWidget()
                                ),
                                /// [Transaction Pie Chart Header]: ==========================================
                                const SizedBox(height: 12),
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                        'Transaction Pie Chart',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                        )
                                    )
                                ),
                                /// [Net Totals Cards]: ===========================================
                                const SizedBox(height: 12),
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: const CategoryDonutChart()
                                ),
                                const SizedBox(height: 80),
                            ]
                        )
                    )
                )
            ),
            /// [Add Transaction Button]: =========================================================
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (_) => const TransactionForm()
                    );
                },
                child: const Icon(Icons.add)
            )
        );
    }
}