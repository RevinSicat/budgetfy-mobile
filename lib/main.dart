import 'package:flutter/material.dart';
import 'package:budgetfy/src/core/connection/supabase_config.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SupabaseConfig.init();
    runApp(const BudgetfyApp());
}

class BudgetfyApp extends StatelessWidget {
    const BudgetfyApp({super.key});

    @override
    Widget build(BuildContext context) {
        return const MaterialApp(
            home: Scaffold(
                body: Center(
                    child: Text('Hello World!'),
                ),
            ),
        );
    }
}