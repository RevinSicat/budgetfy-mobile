import 'package:budgetfy/src/core/connection/supabase_config.dart';
import 'package:budgetfy/src/core/sync/sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restart_app/restart_app.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/theme_provider.dart';
import '../../features/transaction/transaction_provider.dart';

class SettingsScreen extends ConsumerWidget {
    const SettingsScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final theme = Theme.of(context);
        final currentTheme = ref.watch(themeProvider);
        final syncState = ref.watch(syncProvider);
        final isSyncing = syncState.status == SyncStatus.syncing;

        String syncSubtitle() {
            switch (syncState.status) {
                case SyncStatus.syncing:
                    return 'Syncing...';
                case SyncStatus.error:
                    return 'Sync failed — tap to retry';
                case SyncStatus.success:
                case SyncStatus.idle:
                    if (syncState.lastSyncedAt != null) {
                        final t = syncState.lastSyncedAt!;
                        return 'Last synced: ${t.year}-'
                            '${t.month.toString().padLeft(2, '0')}-'
                            '${t.day.toString().padLeft(2, '0')} '
                            '${t.hour.toString().padLeft(2, '0')}:'
                            '${t.minute.toString().padLeft(2, '0')}';
                    }
                    return 'Tap to sync with Supabase';
            }
        }

        return Scaffold(
            appBar: AppBar(
                title: const Text(
                    'Settings',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppFontSize.headline
                    )
                )
            ),
            body: ListView(
                children: [
                    // ── Appearance ──────────────────────────────────────────
                    SectionLabel('Appearance'),
                    ThemePicker(current: currentTheme),

                    // ── Overview ────────────────────────────────────────────
                    SectionLabel('Overview'),
                    SummaryCard(),

                    // ── Data ────────────────────────────────────────────────
                    SectionLabel('Data'),
                    SettingsTile(
                        iconData: Icons.sync,
                        iconColor: theme.colorScheme.primary,
                        title: 'Sync Now',
                        subtitle: syncSubtitle(),
                        subtitleColor: syncState.status == SyncStatus.error
                            ? Colors.red
                            : null,
                        leading: isSyncing
                            ? SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colorScheme.primary
                                )
                            )
                            : null,
                        onTap: isSyncing
                            ? null
                            : () => ref.read(syncProvider.notifier).syncAll()
                    ),

                    // ── Configuration ────────────────────────────────────────
                    SectionLabel('Configuration'),
                    SettingsTile(
                        iconData: Icons.link_off,
                        iconColor: Colors.red,
                        title: 'Reset Supabase Config',
                        subtitle: 'Reconnect to a different Supabase database',
                        onTap: () async {
                            final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                    title: const Text('Reset Supabase Config?'),
                                    content: const Text(
                                        'This will disconnect the app. You will '
                                        'need to re-enter your Supabase credentials.'
                                    ),
                                    actions: [
                                        TextButton(
                                            onPressed: () => Navigator.pop(ctx, false),
                                            child: const Text('Cancel')
                                        ),
                                        TextButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            style: TextButton.styleFrom(
                                                foregroundColor: Colors.red
                                            ),
                                            child: const Text('Reset')
                                        )
                                    ]
                                )
                            );
                            if (confirm != true) return;
                            await SupabaseConfig.clearConfig();
                            Restart.restartApp();
                        }
                    ),

                    const SizedBox(height: 32),
                    Text(
                        'Budgetfy v1.3b · 64c3255',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.4)
                        )
                    ),
                    const SizedBox(height: 24)
                ]
            )
        );
    }
}

// =================================================================================================
// Section label
// =================================================================================================
class SectionLabel extends StatelessWidget {
    final String text;
    const SectionLabel(this.text);

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);
        return Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
                text.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.9,
                    fontWeight: FontWeight.w600
                )
            )
        );
    }
}

// =================================================================================================
// Theme picker — segmented pill row
// =================================================================================================
class ThemePicker extends ConsumerWidget {
    final AppThemeMode current;
    const ThemePicker({required this.current});

    static const _modes = [
        (AppThemeMode.light, 'Light', Icons.light_mode),
        (AppThemeMode.dark, 'Dark', Icons.dark_mode),
        (AppThemeMode.amoled, 'AMOLED', Icons.brightness_1)
    ];

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final theme = Theme.of(context);

        return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
                children: _modes.map((entry) {
                    final (mode, label, icon) = entry;
                    final isActive = current == mode;
                    final color = theme.colorScheme.primary;

                    return Expanded(
                        child: GestureDetector(
                            onTap: () => ref.read(themeProvider.notifier).setTheme(mode),
                            child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin: EdgeInsets.only(
                                    right: entry == _modes.last ? 0 : 8
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 8
                                ),
                                decoration: BoxDecoration(
                                    color: isActive
                                        ? color.withOpacity(0.1)
                                        : theme.cardTheme.color,
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    border: Border.all(
                                        color: isActive
                                            ? color
                                            : theme.dividerColor,
                                        width: isActive ? 2 : 0.5
                                    )
                                ),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        Icon(
                                            icon,
                                            size: 22,
                                            color: isActive
                                                ? color
                                                : theme.colorScheme.onSurface.withOpacity(0.5)
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                            label,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: isActive
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                                color: isActive
                                                    ? color
                                                    : theme.colorScheme.onSurface.withOpacity(0.5)
                                            )
                                        )
                                    ]
                                )
                            )
                        )
                    );
                }).toList()
            )
        );
    }
}

// =================================================================================================
// Summary card — tappable, shows live net totals
// =================================================================================================

class SummaryCard extends ConsumerWidget {
    const SummaryCard();

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final theme = Theme.of(context);
        final netTotals = ref.watch(getTransactionNetTotalsProvider);
        final primary = theme.colorScheme.primary;

        return GestureDetector(
            onTap: () {
                // TODO: navigate to full summary / analytics screen
            },
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                        color: theme.dividerColor,
                        width: 0.5
                    )
                ),
                child: Column(
                    children: [
                        // ── Header row ───────────────────────────────────────
                        Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                                children: [
                                    Container(
                                        width: 40, height: 40,
                                        decoration: BoxDecoration(
                                            color: primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(AppRadius.md)
                                        ),
                                        child: Icon(
                                            Icons.pie_chart,
                                            size: 22,
                                            color: primary
                                        )
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Text(
                                                    'Financial Summary',
                                                    style: theme.textTheme.bodyLarge?.copyWith(
                                                        fontWeight: FontWeight.w600
                                                    )
                                                ),
                                                Text(
                                                    'All-time totals across accounts',
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                        fontSize: AppFontSize.label
                                                    )
                                                )
                                            ]
                                        )
                                    ),
                                    Icon(
                                        Icons.chevron_right,
                                        size: 20,
                                        color: theme.colorScheme.onSurface.withOpacity(0.4)
                                    )
                                ]
                            )
                        ),
                        // ── Stats row ────────────────────────────────────────
                        Divider(
                            height: 0,
                            thickness: 0.5,
                            color: theme.dividerColor
                        ),
                        netTotals.when(
                            loading: () => const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                    child: SizedBox(
                                        width: 20, 
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2)
                                    )
                                )
                            ),
                            error: (e, _) => Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                    'Could not load totals',
                                    style: theme.textTheme.bodyMedium
                                )
                            ),
                            data: (totals) {
                                final income = totals['net_income']  ?? 0.0;
                                final expense = totals['net_expense'] ?? 0.0;
                                final worth = totals['net_worth']   ?? 0.0;

                                return IntrinsicHeight(
                                    child: Row(
                                        children: [
                                            _StatCell(
                                                label: 'Income',
                                                value: '₱${_compact(income)}',
                                                valueColor: Colors.green
                                            ),
                                            VerticalDivider(
                                                width: 0.5,
                                                thickness: 0.5,
                                                color: theme.dividerColor
                                            ),
                                            _StatCell(
                                                label: 'Expenses',
                                                value: '₱${_compact(expense)}',
                                                valueColor: Colors.red
                                            ),
                                            VerticalDivider(
                                                width: 0.5,
                                                thickness: 0.5,
                                                color: theme.dividerColor
                                            ),
                                            _StatCell(
                                                label: 'Net Worth',
                                                value: '₱${_compact(worth)}',
                                                valueColor: worth >= 0
                                                    ? Colors.green
                                                    : Colors.red
                                            )
                                        ]
                                    )
                                );
                            }
                        )
                    ]
                )
            )
        );
    }
    String _compact(double value) {
        if (value.abs() >= 1000000) {
            return '${(value / 1000000).toStringAsFixed(1)}M';
        }
        if (value.abs() >= 1000) {
            return '${(value / 1000).toStringAsFixed(1)}K';
        }
        return value.toStringAsFixed(2);
    }
}

class _StatCell extends StatelessWidget {
    final String label;
    final String value;
    final Color  valueColor;
    const _StatCell({
        required this.label,
        required this.value,
        required this.valueColor
    });

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);
        return Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10, 
                    horizontal: 12
                ),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Text(
                            value,
                            style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize:   AppFontSize.body,
                                color:      valueColor
                            )
                        ),
                        const SizedBox(height: 2),
                        Text(
                            label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: AppFontSize.caption
                            )
                        )
                    ]
                )
            )
        );
    }
}

// =================================================================================================
// Generic settings list tile
// =================================================================================================

class SettingsTile extends StatelessWidget {
    final IconData iconData;
    final Color iconColor;
    final String title;
    final String subtitle;
    final Color? subtitleColor;
    final Widget? leading;
    final VoidCallback? onTap;

    const SettingsTile({
        required this.iconData,
        required this.iconColor,
        required this.title,
        required this.subtitle,
        this.subtitleColor,
        this.leading,
        this.onTap,
    });

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);

        return ListTile(
            leading: leading ?? Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm)
                ),
                child: Icon(iconData, size: 18, color: iconColor)
            ),
            title: Text(title),
            subtitle: Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: subtitleColor
                )
            ),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: onTap
        );
    }
}