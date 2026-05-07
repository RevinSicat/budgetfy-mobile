import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/transaction/transaction_provider.dart';
import '../../../core/theme/design_tokens.dart';

class NetTotalsWidget extends ConsumerWidget {
    const NetTotalsWidget({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final netTotals = ref.watch(getTransactionNetTotalsProvider);
        final theme = Theme.of(context);

        BoxDecoration cardDecoration() => BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: theme.brightness == Brightness.dark
                ? Border.all(color: Colors.white10)
                : Border.all(color: Colors.grey.shade200),
            boxShadow: [
                BoxShadow(
                color: Colors.black.withOpacity(
                    theme.brightness == Brightness.light ? 0.06 : 0.2
                ),
                offset: const Offset(2, 2),
                blurRadius: 4
                )
            ]
        );

        return netTotals.when(
            loading: () => const SizedBox(
                height: 80, 
                child: Center(child: CircularProgressIndicator())
            ),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (totals) {
                final netWorth = totals['net_worth'] ?? 0.0;
                final income = totals['net_income'] ?? 0.0;
                final expenses = totals['net_expense'] ?? 0.0;

                return IntrinsicHeight(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                            /// [Net Worth Card]: =================================================
                            Expanded(
                                flex: 1,
                                child: Container(
                                    padding: const EdgeInsets.only(right: 12),
                                    decoration: cardDecoration(),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                            Icon(
                                                netWorth == 0 
                                                    ? Icons.trending_flat 
                                                    : (netWorth > 0 ? Icons.trending_up 
                                                        : Icons.trending_down),
                                                color: netWorth == 0 
                                                    ? Colors.grey 
                                                    : (netWorth > 0 ? Colors.green 
                                                        : Colors.red),
                                                size: 28,
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min, 
                                                children: [
                                                    Text(
                                                        'Net Worth',
                                                        style: theme.textTheme.bodyLarge?.copyWith(
                                                            color: theme.textTheme.displaySmall?.color,
                                                            fontWeight: FontWeight.bold
                                                        )
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                        '₱${netWorth.toStringAsFixed(2)}',
                                                        style: theme.textTheme.displaySmall?.copyWith(
                                                            color: netWorth > 0 ? Colors.green : Colors.red,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: AppFontSize.headline
                                                        )
                                                    )
                                                ]
                                            )
                                        ]
                                    )
                                )
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                                flex: 1,
                                child: Column(
                                children: [
                                    /// [Net Income Card]: ========================================
                                    Expanded(
                                        child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(AppSpacing.sm),
                                            decoration: cardDecoration(),
                                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                    Text('Net Income',
                                                        style: theme.textTheme.bodySmall?.copyWith(
                                                            fontWeight: FontWeight.bold
                                                        )
                                                    ),
                                                    Text(
                                                        '₱${income.toStringAsFixed(2)}',
                                                        style: theme.textTheme.bodyLarge?.copyWith(
                                                            color: Colors.green,
                                                            fontWeight: FontWeight.bold
                                                        )
                                                    )
                                                ]
                                            )
                                        )
                                    ),
                                    const SizedBox(height: 8),
                                    /// [Net Expense Card]: =======================================
                                    Expanded(
                                        child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(AppSpacing.sm),
                                            decoration: cardDecoration(),
                                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                    Text(
                                                        'Net Expenses',
                                                        style: theme.textTheme.bodySmall?.copyWith(
                                                            fontWeight: FontWeight.bold
                                                        )
                                                    ),
                                                    Text(
                                                        '₱${expenses.toStringAsFixed(2)}',
                                                        style: theme.textTheme.bodyLarge?.copyWith(
                                                            color: Colors.red,
                                                            fontWeight: FontWeight.bold
                                                        )
                                                    )
                                                ]
                                            )
                                        )
                                    )
                                    ]
                                )
                            )
                        ]
                    ),
                );
            }
        );
    }
}