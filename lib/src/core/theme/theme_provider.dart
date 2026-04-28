import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

const themeKey = 'app_theme_mode';

class ThemeNotifier extends Notifier<AppThemeMode> {
    @override
    AppThemeMode build() => AppThemeMode.light;

    Future<void> init() async {
        final prefs = await SharedPreferences.getInstance();
        final saved = prefs.getString(themeKey);
        if (saved != null) {
            state = AppThemeMode.values.firstWhere(
                (e) => e.name == saved,
                orElse: () => AppThemeMode.light,
            );
        }
    }

    Future<void> setTheme(AppThemeMode mode) async {
        state = mode;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(themeKey, mode.name);
    }
}

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(
    ThemeNotifier.new,
);