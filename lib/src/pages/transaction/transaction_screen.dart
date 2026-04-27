import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/transaction/transaction_provider.dart';
import '../../common/widgets/transaction_tile_group_section.dart';

class TransactionScreen extends ConsumerWidget {
    const TransactionScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final transactionList = ref.watch(getAllTransactionByPaginationProvider(const TransactionFilter()));
        final transactionListGrouped = ref.watch(getAllTransactionGroupedByDateByPaginationProvider(const TransactionFilter()));

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
                data: (_) {
                    final entries = transactionListGrouped.entries.toList();
                    
                    if (entries.isEmpty) {
                        return const Center(child: Text("No Transactions Found"));
                    }

                    return ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                            final entry = entries[index];
                            return TransactionGroupSection(
                                date: entry.key, 
                                transactions: entry.value
                            );
                        },
                    );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e'))
            )
        );
    }
}