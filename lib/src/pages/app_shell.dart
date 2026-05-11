import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../src/core/sync/sync_provider.dart';
import '../../src/features/account/account_provider.dart';
import '../../src/features/category/category_provider.dart';
import '../../src/features/transaction/transaction_provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'transaction/transaction_screen.dart';
import 'account/account_screen.dart';
import 'category/category_screen.dart';
import 'settings/settings_screen.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class AppShell extends ConsumerWidget {
    const AppShell({super.key});

    static const List<Widget> appScreens = [
        DashboardScreen(),
        TransactionScreen(),
        AccountScreen(),
        CategoryScreen(),
        SettingsScreen()
    ];

    static const List<NavigationDestination> destinations = [
        NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard'
        ),
        NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions'
        ),
        NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Accounts'
        ),
        NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Categories'
        ),
        NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings'
        )
    ];

    Future<void> _onRefresh(WidgetRef ref) async {
        await ref.read(syncProvider.notifier).syncAll();

        ref.invalidate(getAllAccountListProvider);
        ref.invalidate(getAllCategoryListProvider);
        ref.invalidate(dashboardTransactionNotifierProvider);
        ref.invalidate(transactionListNotifierProvider);
        ref.invalidate(getTransactionNetTotalsProvider);
        ref.invalidate(getCategoryAmountSumByMonthAndYearProvider);
        ref.invalidate(getTotalTransactionAmmountByAccountIdProvider);
        ref.invalidate(getTransactionAmmountSumByCategoryIdProvider);
    }

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final selectedIndex = ref.watch(selectedIndexProvider);

        return Scaffold(
            body: RefreshIndicator(
                onRefresh: () => _onRefresh(ref),
                displacement: 80,
                child: appScreens[selectedIndex]
            ),
            bottomNavigationBar: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) =>
                    ref.read(selectedIndexProvider.notifier).state = index,
                destinations: destinations
            )
        );
    }
}