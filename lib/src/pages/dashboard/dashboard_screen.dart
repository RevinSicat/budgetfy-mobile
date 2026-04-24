import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/account/account_provider.dart';
import '../../features/transaction/transaction_provider.dart';
import '../../common/widgets/account_card.dart';
import '../../common/widgets/transaction_tile.dart';
import 'widgets/greeting_header.dart';
import '../../features/account/account.dart';
import '../../common/widgets/add_account_card.dart';
import '../../common/widgets/account_form.dart';

class DashboardScreen extends ConsumerWidget{
    const DashboardScreen({super.key});

    void openAccountForm(BuildContext context, {Account? account}) {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true, // allows form to resize with keyboard
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => AccountForm(account: account),
        );
    }

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final accountList = ref.watch(getAllAccountListProvider);
        final transactionList = ref.watch(getAllTransactionByPaginationProvider(const TransactionFilter()));

        return Scaffold(
            backgroundColor: const Color(0xFFF9F9F9),
            body: SafeArea(
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            const Padding(
                                padding: EdgeInsets.all(16), 
                                child: GreetingHeader()
                            ),

                            const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                    'Accounts',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold
                                    ),
                                )
                            ),

                            const SizedBox(height: 8),
                            SizedBox(
                                height: 120,
                                child: accountList.when(
                                    data: (accounts) => ListView(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.only(left: 16),
                                        children: [
                                            ...accounts.map((acc) => AccountCard(account: acc)),
                                            AddAccountCard(onTap: () => openAccountForm(context))
                                        ],
                                    ), 
                                    loading: () => const Center(child: CircularProgressIndicator()),
                                    error: (e, _) => Center(child: Text('Error: $e'))
                                ),
                            ),

                            const SizedBox(height: 24),
                            
                            const Padding(
                                padding: const EdgeInsetsGeometry.symmetric(horizontal: 16),
                                child: Text(
                                    'Transactions',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold
                                    ),
                                )
                            ),

                            const SizedBox(height: 8),
                            transactionList.when(
                                data: (transaction) => Column(
                                    children: transaction.map((trn) => TransactionTile(transaction: trn)).toList()
                                ), 
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (e, _) => Center(child: Text('Error: $e'))
                            )
                        ],
                    ),
                ),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                    // TODO: Open Transaction Form
                },
                child: const Icon(Icons.add),
            ),
        );
    }
}