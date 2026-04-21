import 'package:flutter/material.dart';
import 'package:budgetfy/src/core/connection/supabase_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgetfy/src/pages/account/account_screen.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SupabaseConfig.init();
    runApp(const ProviderScope(
        child: BudgetfyApp()
    ));
}

class BudgetfyApp extends StatelessWidget {
    const BudgetfyApp({super.key});

    @override
    Widget build(BuildContext context) {
        return const MaterialApp(
            home: AccountScreen(), // <- swap this in
        );
    }
}