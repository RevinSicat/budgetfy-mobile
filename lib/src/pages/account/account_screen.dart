import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/account/account_provider.dart';
import '../../common/widgets/account_card.dart';
import '../../common/widgets/add_account_card.dart';

class AccountScreen extends ConsumerWidget {
    const AccountScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final theme = Theme.of(context);
        final accountList = ref.watch(getAllAccountListProvider);

        return Scaffold(
            appBar: AppBar(title: Text(
                'Accounts',
                style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold
                )
            )),
            body: accountList.when(
                data: (accounts) => SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                            ...accounts.map((acc) => AccountCard(account: acc)),
                            AddAccountCard()
                        ]
                    ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
            )
        );
    }
}