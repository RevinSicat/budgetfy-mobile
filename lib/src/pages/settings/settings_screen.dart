import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
    const SettingsScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final theme = Theme.of(context);
        final currentTheme = ref.watch(themeProvider);

        return Scaffold(
            appBar: AppBar(
                title: const Text(
                    'Settings',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)
                )
            ),
            body: ListView(
                children: [
                    Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                            'Appearance',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary
                            )
                        )
                    ),
                    ...AppThemeMode.values.map((mode) {
                        final labels = {
                            AppThemeMode.light: ('Light', Icons.light_mode),
                            AppThemeMode.dark: ('Dark', Icons.dark_mode),
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
                    })
                ]
            )
        );
    }
}