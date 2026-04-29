import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/account/account_provider.dart';
import '../../features/transaction/transaction_provider.dart';
import '../../common/widgets/cards/account_card.dart';
import '../../common/widgets/tiles/transaction_tile_group_section.dart';
import 'widgets/greeting_header.dart';
import '../../features/account/account.dart';
import '../../common/widgets/cards/add_account_card.dart';
import '../../common/widgets/forms/account_form.dart';
import '../../common/widgets/forms/transaction_form.dart';

class DashboardScreen extends ConsumerWidget{
    const DashboardScreen({super.key});

    void openAccountForm(BuildContext context, {Account? account}) {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => AccountForm(account: account),
        );
    }

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final theme = Theme.of(context);
        final accountList = ref.watch(getAllAccountListProvider);
        final transactionList = ref.watch(getAllTransactionByPaginationProvider(const TransactionFilter()));
        final transactionListGrouped = ref.watch(getAllTransactionGroupedByDateByPaginationProvider(const TransactionFilter()));

        return Scaffold(
            body: SafeArea(
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            // Greetings Header
                            const Padding(
                                padding: EdgeInsets.all(16), 
                                child: GreetingHeader()
                            ),
                            // Accounts Header
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                    'Accounts',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold
                                    )
                                )
                            ),
                            // Account Card List
                            const SizedBox(height: 8),
                            SizedBox(
                                height: 120,
                                child: accountList.when(
                                    data: (accounts) => ListView(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.only(left: 16),
                                        children: [
                                            ...accounts.map((acc) => AccountCard(account: acc)),
                                            AddAccountCard()
                                        ],
                                    ), 
                                    loading: () => const Center(child: CircularProgressIndicator()),
                                    error: (e, _) => Center(child: Text('Error: $e'))
                                ),
                            ),
                            // Transactions Header
                            const SizedBox(height: 24),
                            Padding(
                                padding: const EdgeInsetsGeometry.symmetric(horizontal: 16),
                                child: Text(
                                    'Transactions',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold
                                    )
                                )
                            ),
                            // Transaction Tile List
                            const SizedBox(height: 8),
                            transactionList.when(
                                data: (_) {
                                    if (transactionListGrouped.isEmpty) {
                                        return const Center(
                                            child: Text("No Transactions Found"),
                                        );
                                    }
                                    return Column(
                                        children: transactionListGrouped.entries.map((entry) {
                                            return TransactionGroupSection(
                                                date: entry.key, 
                                                transactions: entry.value
                                            );
                                        }).toList()
                                    );
                                },
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (e, _) => Center(child: Text('Error: $e'))
                            )
                        ],
                    ),
                ),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (_) => const TransactionForm(),
                    );
                },
                child: const Icon(Icons.add),
            ),
        );
    }
}