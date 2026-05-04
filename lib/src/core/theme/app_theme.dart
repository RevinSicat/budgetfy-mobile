import 'package:flutter/material.dart';
import 'design_tokens.dart';

enum AppThemeMode { 
    light, 
    dark, 
    amoled 
}

class AppTheme {
    AppTheme._();

    static ThemeData fromMode(AppThemeMode mode) {
        switch (mode) {
            case AppThemeMode.light: return light;
            case AppThemeMode.dark: return dark;
            case AppThemeMode.amoled: return amoled;
        }
    }

    /// [Light Theme]: ============================================================================
    static ThemeData light = ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF2E7D32),
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),

        cardTheme: CardThemeData(
            color: Colors.white,
            elevation: AppElevation.none,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                side: BorderSide(color: Colors.grey.shade200),
            ),
        ),

        textTheme: const TextTheme(
            displaySmall: TextStyle(
                fontSize: AppFontSize.display,
                fontWeight: AppFontWeight.bold,
                color: Color(0xFF1A1A1A)
            ),
            headlineMedium: TextStyle(
                fontSize: AppFontSize.headline,
                fontWeight: AppFontWeight.bold,
                color: Color(0xFF1A1A1A)
            ),
            titleLarge: TextStyle(
                fontSize: AppFontSize.title,
                fontWeight: AppFontWeight.bold,
                color: Color(0xFF1A1A1A)
            ),
            titleMedium: TextStyle(
                fontSize: AppFontSize.bodyLg,
                fontWeight: AppFontWeight.semiBold,
                color: Color(0xFF1A1A1A)
            ),
            bodyLarge: TextStyle(
                fontSize: AppFontSize.bodyLg,
                fontWeight: AppFontWeight.regular,
                color: Color(0xFF1A1A1A)
            ),
            bodyMedium: TextStyle(
                fontSize: AppFontSize.body,
                fontWeight: AppFontWeight.regular,
                color: Color(0xFF757575)
            ),
            labelLarge: TextStyle(
                fontSize: AppFontSize.label,
                fontWeight: AppFontWeight.semiBold,
                color: Color(0xFF1A1A1A)
            ),
            labelSmall: TextStyle(
                fontSize: AppFontSize.caption,
                fontWeight: AppFontWeight.bold,
                color: Color(0xFF9E9E9E)
            ),
        ),

        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF9F9F9),
            elevation: AppElevation.none,
            centerTitle: false,
            foregroundColor: Color(0xFF1A1A1A),
            titleTextStyle: TextStyle(
                fontSize: AppFontSize.headline,
                fontWeight: AppFontWeight.bold,
                color: Color(0xFF1A1A1A)
            ),
        ),

        navigationBarTheme: NavigationBarThemeData(
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md)
            )
        )
    );

    /// [Dark Theme]: =============================================================================
    static ThemeData dark = ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF64B5F6),
        scaffoldBackgroundColor: const Color(0xFF121416),

        cardTheme: CardThemeData(
            color: const Color(0xFF1E2125),
            elevation: AppElevation.none,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg)
            )
        ),

        textTheme: const TextTheme(
            displaySmall: TextStyle(
                fontSize: AppFontSize.display,
                fontWeight: AppFontWeight.bold,
                color: Colors.white
            ),
            headlineMedium: TextStyle(
                fontSize: AppFontSize.headline,
                fontWeight: AppFontWeight.bold,
                color: Colors.white
            ),
            titleLarge: TextStyle(
                fontSize: AppFontSize.title,
                fontWeight: AppFontWeight.bold,
                color: Colors.white
            ),
            titleMedium: TextStyle(
                fontSize: AppFontSize.bodyLg,
                fontWeight: AppFontWeight.semiBold,
                color: Colors.white
            ),
            bodyLarge: TextStyle(
                fontSize: AppFontSize.bodyLg,
                fontWeight: AppFontWeight.regular,
                color: Color(0xFFE1E1E1)
            ),
            bodyMedium: TextStyle(
                fontSize: AppFontSize.body,
                fontWeight: AppFontWeight.regular,
                color: Color(0xFFB0B0B0)
            ),
            labelLarge: TextStyle(
                fontSize: AppFontSize.label,
                fontWeight: AppFontWeight.semiBold,
                color: Colors.white
            ),
            labelSmall: TextStyle(
                fontSize: AppFontSize.caption,
                fontWeight: AppFontWeight.bold,
                color: Colors.grey
            )
        ),

        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF121416),
            elevation: AppElevation.none,
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
                fontSize: AppFontSize.headline,
                fontWeight: AppFontWeight.bold,
                color: Colors.white
            )
        ),

        navigationBarTheme: NavigationBarThemeData(
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md)
            )
        )
    );

    /// [Amodled Theme]: ==========================================================================
    static ThemeData amoled = ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFFCCFF90),
        scaffoldBackgroundColor: Colors.black,

        cardTheme: CardThemeData(
            color: const Color(0xFF121212),
            elevation: AppElevation.none,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                side: BorderSide(color: Colors.white.withOpacity(0.1))
            )
        ),

        textTheme: const TextTheme(
            displaySmall: TextStyle(
                fontSize: AppFontSize.display,
                fontWeight: AppFontWeight.bold,
                color: Colors.white
            ),
            headlineMedium: TextStyle(
                fontSize: AppFontSize.headline,
                fontWeight: AppFontWeight.bold,
                color: Colors.white
            ),
            titleLarge: TextStyle(
                fontSize: AppFontSize.title,
                fontWeight: AppFontWeight.bold,
                color: Colors.white
            ),
            titleMedium: TextStyle(
                fontSize: AppFontSize.bodyLg,
                fontWeight: AppFontWeight.semiBold,
                color: Colors.white
            ),
            bodyLarge: TextStyle(
                fontSize: AppFontSize.bodyLg,
                fontWeight: AppFontWeight.regular,
                color: Colors.white
            ),
            bodyMedium: TextStyle(
                fontSize: AppFontSize.body,
                fontWeight: AppFontWeight.regular,
                color: Colors.grey
            ),
            labelLarge: TextStyle(
                fontSize: AppFontSize.label,
                fontWeight: AppFontWeight.semiBold,
                color: Colors.white
            ),
            labelSmall: TextStyle(
                fontSize: AppFontSize.caption,
                fontWeight: AppFontWeight.bold,
                color: Colors.grey
            )
        ),

        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            elevation: AppElevation.none,
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
                fontSize: AppFontSize.headline,
                fontWeight: AppFontWeight.bold,
                color: Colors.white
            )
        ),

        navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.black,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md)
            )
        )
    );
}