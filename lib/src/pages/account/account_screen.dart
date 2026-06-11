import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/account/account_provider.dart';
import '../../common/widgets/cards/account_card.dart';
import '../../common/widgets/cards/add_account_card.dart';

class AccountScreen extends ConsumerWidget {
    const AccountScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final theme = Theme.of(context);
        final accountList = ref.watch(getAllAccountListProvider);
        final screenW = MediaQuery.of(context).size.width;
        final columns = screenW < 480 ? 1.25 : (screenW < 840 ? 2 : 3);
        const spacing = 20.0;
        const padding = 16.0;
        final cardW = (screenW - padding * 2 - spacing * (columns - 1)) / columns;
        final cardH = cardW / 1.7;

        return Scaffold(
            appBar: AppBar(
                title: Text(
                    'Accounts',
                    style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold
                    )
                )
            ),
            body: accountList.when(
                data: (accounts) {
                    if (accounts.isEmpty) {
                        return const Center(
                            child: Text('No Accounts found.')
                        );
                    }

                    return SingleChildScrollView(
                        padding: const EdgeInsets.all(padding),
                        child: Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: [
                                ...accounts.map(
                                    (acc) => SizedBox(
                                        width:  cardW,
                                        height: cardH,
                                        child:  AccountCard(account: acc)
                                    )
                                ),
                                SizedBox(
                                    width: cardW,
                                    height: cardH,
                                    child: const AddAccountCard()
                                )
                            ]
                        )
                    );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
            )
        );
    }
}