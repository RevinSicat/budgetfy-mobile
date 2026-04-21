import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/utils/color_utility.dart';
import '../../features/account/account_provider.dart';

class AccountScreen extends ConsumerWidget {
    const AccountScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final accountList = ref.watch(getAllListProvider);
        return Scaffold(
            appBar: AppBar(title: const Text('Accounts')),
            body: accountList.when(
                data: (accounts) => ListView.builder(
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                        final account = accounts[index];
                        return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: hexToColor(account.color),
                                    width: 2
                                ),
                                borderRadius: BorderRadius.circular(8)
                            ),
                            child: ListTile(
                                title: Text(account.name)
                            )
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