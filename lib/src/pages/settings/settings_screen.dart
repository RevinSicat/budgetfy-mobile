import 'package:budgetfy/src/core/connection/supabase_config.dart';
import 'package:budgetfy/src/core/sync/sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restart_app/restart_app.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/theme_provider.dart';

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
                        return 'Last synced: ${t.year}-${t.month.toString().padLeft(2,'0')}-${t.day.toString().padLeft(2,'0')} '
                            '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
                    }
                    return 'Tap to sync with Supabase';
            }
        }

        return Scaffold(
            /// [Settings Header]: ================================================================
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
                    /// [Appearance Subheader]: ===================================================
                    Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                            'Appearance',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary
                            )
                        )
                    ),
                    /// [Theme Selection List]: ===================================================
                    ...AppThemeMode.values.map((mode) {
                        final labels = {
                            AppThemeMode.light:  ('Light',        Icons.light_mode),
                            AppThemeMode.dark:   ('Dark',         Icons.dark_mode),
                            AppThemeMode.amoled: ('AMOLED Black', Icons.brightness_1)
                        };
                        final (label, icon) = labels[mode]!;

                        return ListTile(
                            leading: Icon(icon),
                            title: Text(label),
                            trailing: currentTheme == mode
                                ? Icon(Icons.check, color: theme.colorScheme.primary)
                                : null,
                            onTap: () => ref.read(themeProvider.notifier).setTheme(mode)
                        );
                    }),

                    const SizedBox(height: 8),

                    /// [Sync Subheader]: =========================================================
                    Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                            'Data',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary
                            )
                        )
                    ),
                    /// [Sync Now]: ===============================================================
                    ListTile(
                        leading: isSyncing
                            ? SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colorScheme.primary,
                                )
                            )
                            : Icon(
                                Icons.sync,
                                color: syncState.status == SyncStatus.error
                                    ? Colors.red
                                    : theme.colorScheme.primary,
                            ),
                        title: const Text('Sync Now'),
                        subtitle: Text(
                            syncSubtitle(),
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: syncState.status == SyncStatus.error
                                    ? Colors.red
                                    : null,
                            ),
                        ),
                        onTap: isSyncing
                            ? null
                            : () => ref.read(syncProvider.notifier).syncAll(),
                    ),

                    const SizedBox(height: 8),

                    /// [Configuration Subheader]: ================================================
                    Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                            'Configuration',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary
                            )
                        )
                    ),
                    /// [Reset Supabase Configuration]: ===========================================
                    ListTile(
                        leading: const Icon(Icons.link_off, color: Colors.red),
                        title: const Text('Reset Supabase Config'),
                        subtitle: const Text('Reconnect to a different Supabase database'),
                        onTap: () async {
                            final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                    title: const Text('Reset Supabase Config?'),
                                    content: const Text(
                                        'This will disconnect the app. You will need to re-enter your Supabase credentials.'
                                    ),
                                    actions: [
                                        TextButton(
                                            onPressed: () => Navigator.pop(ctx, false),
                                            child: const Text('Cancel')
                                        ),
                                        TextButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            style: TextButton.styleFrom(foregroundColor: Colors.red),
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

                    const SizedBox(height: 8),
                    /// [App Versioning]: =========================================================
                    Text(
                        'Budgetfy v.1.3b stable\n',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall
                    )
                ]
            )
        );
    }
}