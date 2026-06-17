import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard/widgets/category_donut_chart.dart';
import '../dashboard/widgets/net_totals_widget.dart';

class SummaryScreen extends ConsumerWidget {
    const SummaryScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final theme = Theme.of(context);

        return Scaffold(
            appBar: AppBar(
                title: Text(
                    'Summary',
                    style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold
                    )
                )
            ),
            body: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                    // ── Net Totals Header ───────────────────────────────────
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                            'Net Totals',
                            style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold
                            )
                        )
                    ),
                    const SizedBox(height: 12),
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: NetTotalsWidget()
                    ),

                    const SizedBox(height: 12),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Divider(
                            height: 24,
                            thickness: 1,
                            color: theme.dividerColor.withOpacity(0.2)
                        )
                    ),

                    // ── Category Breakdown Header ───────────────────────────
                    const SizedBox(height: 4),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                            'Category Breakdown',
                            style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold
                            )
                        )
                    ),
                    const SizedBox(height: 12),
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: CategoryDonutChart()
                    ),

                    const SizedBox(height: 32)
                ]
            )
        );
    }
}