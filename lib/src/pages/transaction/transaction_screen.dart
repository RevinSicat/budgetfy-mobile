import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/transaction/transaction_provider.dart';
import '../../common/widgets/transaction_tile.dart';

class TransactionScreen extends ConsumerWidget {
    const TransactionScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final transactionList = ref.watch(
            getAllTransactionByPaginationProvider(const TransactionFilter())
        );

        return Scaffold(
            appBar: AppBar(title: const Text(
                'Transactions',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                ),
            )),
            backgroundColor: const Color(0xFFF9F9F9),
            body: transactionList.when(
                data: (transactions) => ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) => TransactionTile(
                        transaction: transactions[index]
                    ),
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