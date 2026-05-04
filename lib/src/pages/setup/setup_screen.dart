import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/connection/supabase_config.dart';
import '../app_shell.dart';

class SetupScreen extends ConsumerStatefulWidget {
    const SetupScreen({super.key});

    @override
    ConsumerState<SetupScreen> createState() => SetupScreenState();
}

class SetupScreenState extends ConsumerState<SetupScreen> {
    final urlController = TextEditingController();
    final anonKeyController = TextEditingController();
    bool isLoading = false;
    String? errorMessage;

    @override
    void dispose() {
        urlController.dispose();
        anonKeyController.dispose();
        super.dispose();
    }

    Future<void> submit() async {
        final url = urlController.text.trim();
        final anonKey = anonKeyController.text.trim();

        if (url.isEmpty || anonKey.isEmpty) {
            setState(() => errorMessage = 'Both fields are required.');
            return;
        }
        if (!url.startsWith('https://')) {
            setState(() => errorMessage = 'URL must start with https://');
            return;
        }

        setState(() {
            isLoading = true;
            errorMessage = null;
        });

        try {
            await SupabaseConfig.saveConfig(url, anonKey);

            if (SupabaseConfig.isInitialized) {
                Restart.restartApp();
            } else {
                await Supabase.initialize(url: url, anonKey: anonKey);
                if (mounted) {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const AppShell()),
                    );
                }
            }
        } catch (e) {
            await SupabaseConfig.clearConfig();
            setState(() {
                isLoading = false;
                errorMessage = 'Could not connect to Supabase. Check your URL and anon key.';
            });
        }
    }
    
    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);

        return Scaffold(
            body: SafeArea(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            const SizedBox(height: 40),
                            /// [Cloud Sync Icon]: ================================================ 
                            Center(
                                child: Icon(
                                    Icons.cloud_sync,
                                    size: 64,
                                    color: theme.colorScheme.primary,
                                ),
                            ),
                            const SizedBox(height: 24),
                            /// [Setup Budgetfy Header]: ==========================================
                            Center(
                                child: Text(
                                    'Setup Budgetfy',
                                    style: theme.textTheme.titleLarge,
                                ),
                            ),
                            const SizedBox(height: 8),
                            /// [Connect your Supabase description]: ==============================
                            Center(
                                child: Text(
                                    'Connect your Supabase database to get started.',
                                    style: theme.textTheme.bodyMedium,
                                    textAlign: TextAlign.center
                                )
                            ),
                            const SizedBox(height: 40),
                            /// [Supabase URL Label]: =============================================
                            Text(
                                'Supabase URL', 
                                style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600
                                )
                            ),
                            const SizedBox(height: 8),
                            /// [Supabase URL Field]: =============================================
                            TextField(
                                controller: urlController,
                                decoration: const InputDecoration(
                                    hintText: 'https://your-project.supabase.co',
                                    border: OutlineInputBorder()
                                ),
                                keyboardType: TextInputType.url,
                                autocorrect: false
                            ),
                            const SizedBox(height: 16),
                            /// [Supabase Anon Key Label]: ========================================
                            Text(
                                'Anon Key', 
                                style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600
                                )
                            ),
                            const SizedBox(height: 8),
                            /// [Supabase Anon Key Field]: ========================================
                            TextField(
                                controller: anonKeyController,
                                decoration: const InputDecoration(
                                    hintText: 'eyJhbGciOiJIUzI1NiIs...',
                                    border: OutlineInputBorder()
                                ),
                                autocorrect: false,
                                obscureText: true
                            ),
                            const SizedBox(height: 24),
                            /// [Error Message]: ==================================================
                            if (errorMessage != null)
                                Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Text(
                                        errorMessage!,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                            color: Colors.red
                                        )
                                    )
                                ),
                            /// [Connect your Supabase description 2]: ============================
                            Center(
                                child: Text(
                                    'This will be used to save and syncronize all of your Transactions, Accounts, and Categories in Budgetfy',
                                    style: theme.textTheme.bodyMedium,
                                    textAlign: TextAlign.center
                                )
                            ),
                            const SizedBox(height: 24),
                            /// [Connect to Supabase Button]: =====================================
                            SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                    onPressed: isLoading ? null : submit,
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 20, width: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                        : const Text('Connect')
                                )
                            ),
                            const SizedBox(height: 16),
                            /// [Connect your Supabase description 3]: ============================
                            Center(
                                child: Text(
                                    'You can find these in your Supabase project\nunder Settings → API',
                                    style: theme.textTheme.bodyMedium,
                                    textAlign: TextAlign.center
                                )
                            )
                        ]
                    )
                )
            )
        );
    }
}