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

    runApp(ProviderScope(
        child: BudgetfyApp(supabaseReady: supabaseReady),
    ));
}

class BudgetfyApp extends ConsumerWidget {
    final bool supabaseReady;
    const BudgetfyApp({
        super.key, 
        required this.supabaseReady
    });

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final themeMode = ref.watch(themeProvider);
        ref.read(themeProvider.notifier).init();

        return MaterialApp(
            theme: AppTheme.fromMode(themeMode),
            home: supabaseReady 
                ? const AppShell() 
                : const SetupScreen(),
        );
    }
}