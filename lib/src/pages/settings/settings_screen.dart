import 'package:budgetfy/src/core/connection/supabase_config.dart';
import 'package:budgetfy/src/core/sync/sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restart_app/restart_app.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/theme_provider.dart';
import '../summary/summary_screen.dart';

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
                    Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Row(
                                    children: [
                                        Container(
                                        width: 40, height: 40,
                                            decoration: BoxDecoration(
                                                color: theme.colorScheme.primary.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(AppRadius.md)
                                            ),
                                            child: Icon(
                                                Icons.palette_outlined,
                                                size: 22,
                                                color: theme.colorScheme.primary
                                            )
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                            'Theme',
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                                fontSize:   AppFontSize.body,
                                                fontWeight: FontWeight.w600
                                            )
                                        ),
                                    ]
                                ),
                                ThemeSection(current: currentTheme)
                            ]
                        )
                    ),

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

                    // ── Overview ────────────────────────────────────────────
                    SectionLabel('Overview'),
                    SettingsTile(
                        iconData: Icons.query_stats,
                        iconColor: theme.colorScheme.primary,
                        title: 'Summary',
                        subtitle: 'View net totals and category breakdown',
                        onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SummaryScreen(),
                                ),
                            );
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
// Theme dropdown
// =================================================================================================
class ThemeSection extends ConsumerWidget {
    final AppThemeMode current;
    const ThemeSection({required this.current});

    static const _modes = [
        (AppThemeMode.light, 'Light', Icons.light_mode),
        (AppThemeMode.dark, 'Dark', Icons.dark_mode),
        (AppThemeMode.amoled, 'AMOLED', Icons.brightness_1)
    ];

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final theme = Theme.of(context);

        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(AppRadius.md)
            ),
            child: DropdownButtonHideUnderline(
                child: DropdownButton<AppThemeMode>(
                    value: current,
                    isDense: true,
                    icon: const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.expand_more, size: 18)
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: AppFontSize.label,
                        fontWeight: AppFontWeight.semiBold,
                        color: theme.colorScheme.onSurface
                    ),
                    selectedItemBuilder: (context) => _modes.map((entry) {
                        final (_, label, icon) = entry;
                        return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                Icon(icon, size: 16, color: theme.colorScheme.primary),
                                const SizedBox(width: 6),
                                Text(label)
                            ]
                        );
                    }).toList(),
                    items: _modes.map((entry) {
                        final (mode, label, icon) = entry;
                        return DropdownMenuItem(
                            value: mode,
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                    Icon(icon, size: 18),
                                    const SizedBox(width: 10),
                                    Text(label)
                                ]
                            )
                        );
                    }).toList(),
                    onChanged: (mode) {
                        if (mode != null) {
                            ref.read(themeProvider.notifier).setTheme(mode);
                        }
                    }
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
            title: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize:   AppFontSize.body,
                    fontWeight: FontWeight.w600
                )
            ),
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