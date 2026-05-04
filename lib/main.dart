import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgetfy/src/core/connection/supabase_config.dart';
import 'package:budgetfy/src/core/theme/app_theme.dart';
import 'package:budgetfy/src/core/theme/theme_provider.dart';
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