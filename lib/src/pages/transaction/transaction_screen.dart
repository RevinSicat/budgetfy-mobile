import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/transaction/transaction_provider.dart';
import '../../common/utils/color_utility.dart';

class TransactionScreen extends ConsumerWidget {
    const TransactionScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final transactionList = ref.watch(
            getAllTransactionByPaginationProvider(const TransactionFilter())
        );

        return Scaffold(
            appBar: AppBar(title: const Text('Transactions')),
            body: transactionList.when(
                data: (transactions) => ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: transaction.category != null
                                        ? hexToColor(transaction.category!.color)
                                        : Colors.grey,
                                ),
                            ),
                            child: ListTile(
                                title: Text(
                                    transaction.category?.name ?? 'Uncategorized',
                                ),
                                trailing: Text(transaction.amount.toStringAsFixed(2)),
                            ),
                        );
                    }
                ),
                loading: () => const Center(
                    child: CircularProgressIndicator()
                ),
                error: (e, _) => Center(
                    child: Text('Error encountered: $e')
                )
            ),
        );
    }
}