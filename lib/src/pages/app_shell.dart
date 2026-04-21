import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction/transaction_screen.dart';
import 'account/account_screen.dart';
import 'category/category_screen.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class AppShell extends ConsumerWidget {
    const AppShell({super.key});

    static const List<Widget> appScreens = [
        TransactionScreen(),
        AccountScreen(),
        CategoryScreen(),
    ];

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final selectedIndex = ref.watch(selectedIndexProvider);

        return Scaffold(
            body: appScreens[selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
                currentIndex: selectedIndex,
                onTap: (index) => ref.read(selectedIndexProvider.notifier).state = index,
                type: BottomNavigationBarType.fixed,
                items: const [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.receipt_long),
                        label: 'Transactions',
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.account_balance_wallet),
                        label: 'Accounts',
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.category),
                        label: 'Categories',
                    )
                ]
            )
        );
    }
}