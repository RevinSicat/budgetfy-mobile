import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/transaction/transaction_provider.dart';
import '../../common/widgets/tiles/transaction_tile_group_section.dart';
import '../../common/widgets/forms/transaction_form.dart';

class TransactionScreen extends ConsumerStatefulWidget {
    const TransactionScreen({super.key});

    @override
    ConsumerState<TransactionScreen> createState() => TransactionScreenState();
}

class TransactionScreenState extends ConsumerState<TransactionScreen> {
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
            ref.read(transactionListNotifierProvider.notifier).fetchMore();
        }
    }

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);
        final transactionList = ref.watch(transactionListNotifierProvider);
        final grouped = ref.watch(transactionListGroupedProvider);
        final notifier = ref.read(transactionListNotifierProvider.notifier);

        return Scaffold(
            /// [Transaction Header]: =============================================================
            appBar: AppBar(
                title: Text(
                    'Transactions',
                    style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                    )
                )
            ),
            /// [Transaction Tile List]: ==========================================================
            body: transactionList.when(
                data: (_) {
                    final entries = grouped.entries.toList();

                    if (entries.isEmpty) {
                        return const Center(
                            child: Text('No Transactions Found')
                        );
                    }

                    return ListView.builder(
                        controller: scrollController,
                        itemCount: entries.length + 1,
                        itemBuilder: (context, index) {
                            if (index == entries.length) {
                                return notifier.hasMore
                                    ? const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Center(child: CircularProgressIndicator())
                                    )
                                    : const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Center(
                                            child: Text(
                                                'No more transactions',
                                                style: TextStyle(color: Colors.grey)
                                            )
                                        )
                                    );
                            }
                            final entry = entries[index];
                            return TransactionGroupSection(
                                date: entry.key,
                                transactions: entry.value
                            );
                        }
                    );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e'))
            ),
            /// [Add Transaction Button]: =========================================================
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16)
                            )
                        ),
                        builder: (_) => const TransactionForm()
                    );
                },
                child: const Icon(Icons.add)
            )
        );
    }
}