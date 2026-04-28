import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgetfy/src/core/connection/supabase_config.dart';
import 'package:budgetfy/src/core/theme/app_theme.dart';
import 'package:budgetfy/src/core/theme/theme_provider.dart';
import 'package:budgetfy/src/pages/app_shell.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SupabaseConfig.init();
    runApp(const ProviderScope(child: BudgetfyApp()));
}

class BudgetfyApp extends ConsumerWidget {
    const BudgetfyApp({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final themeMode = ref.watch(themeProvider);

        ref.read(themeProvider.notifier).init();

        return MaterialApp(
            theme: AppTheme.fromMode(themeMode),
            home: const AppShell(),
        );
    }
}