import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../category/category.dart';
import 'transaction_provider.dart';

class TransactionScreen extends ConsumerWidget {
    const TransactionScreen({super.key});

    Color hexToColor(String hex) {
        hex = hex.replaceAll('#', '');
        if (hex.length == 6) {
            hex = 'FF$hex';
        }
        return Color(int.parse(hex, radix: 16));
    }

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final transactionList = ref.watch(transactionListProvider);
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
                                    color: transaction.category?.color != null
                                        ? hexToColor(transaction.category!.color)
                                        : (transaction.category?.type == CategoryType.income ? Colors.green : Colors.red),
                                ),
                            ),
                            child: ListTile(
                                title: Text(
                                    transaction.category?.name 
                                    ?? (transaction.amount > 0 ? 'Uncategorized Income' : 'Uncategorized Expense'),
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