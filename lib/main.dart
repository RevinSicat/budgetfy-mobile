import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:budgetfy/src/core/connection/supabase_config.dart';
import 'package:budgetfy/src/core/theme/app_theme.dart';
import 'package:budgetfy/src/core/theme/theme_provider.dart';
import 'package:budgetfy/src/core/sync/sync_provider.dart';
import 'package:budgetfy/src/pages/app_shell.dart';
import 'package:budgetfy/src/pages/setup/setup_screen.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    final supabaseReady = await SupabaseConfig.init();
    runApp(
        ProviderScope(
            child: BudgetfyApp(supabaseReady: supabaseReady),
        )
    );
}

class BudgetfyApp extends ConsumerStatefulWidget {
    final bool supabaseReady;
    const BudgetfyApp({
        super.key,
        required this.supabaseReady
    });

    @override
    ConsumerState<BudgetfyApp> createState() => _BudgetfyAppState();
}

class _BudgetfyAppState extends ConsumerState<BudgetfyApp> {
    @override
    void initState() {
        super.initState();
        ref.read(themeProvider.notifier).init();

        if (widget.supabaseReady) {
            _syncOnLaunch();
        }
    }

    Future<void> _syncOnLaunch() async {
        final connectivity = await Connectivity().checkConnectivity();
        final isOnline = connectivity != ConnectivityResult.none;
        if (!isOnline) return;

        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
            await ref.read(syncProvider.notifier).syncAll();
        }
    }

    @override
    Widget build(BuildContext context) {
        final themeMode = ref.watch(themeProvider);

        return MaterialApp(
            theme: AppTheme.fromMode(themeMode),
            home: widget.supabaseReady
                ? const AppShell()
                : const SetupScreen(),
        );
    }
}