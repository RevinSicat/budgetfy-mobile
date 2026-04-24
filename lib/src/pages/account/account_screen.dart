import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/account/account_provider.dart';
import '../../common/widgets/account_card.dart';

class AccountScreen extends ConsumerWidget {
    const AccountScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final accountList = ref.watch(getAllAccountListProvider);
        return Scaffold(
            appBar: AppBar(title: const Text(
                'Accounts',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                )
            )),
            backgroundColor: const Color(0xFFF9F9F9),
            body: accountList.when(
                data: (accounts) => SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                    spacing: 12, // horizontal spacing between cards
                    runSpacing: 12, // vertical spacing between rows
                    children: accounts.map((acc) => AccountCard(account: acc)).toList(),
                    ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
            )
        );
    }
}