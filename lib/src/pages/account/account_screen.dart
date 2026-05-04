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

        return Scaffold(
            /// [Account Header]: =================================================================
            appBar: AppBar(title: Text(
                'Accounts',
                style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold
                )
            )),
            /// [Account Cards List]: =============================================================
            body: accountList.when(
                data: (accounts) {
                    if (accounts.isEmpty) {
                        return const Center(
                            child: Text('No Accounts found.')
                        );
                    }

                    return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                                ...accounts.map((acc) => AccountCard(account: acc)),
                                AddAccountCard()
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