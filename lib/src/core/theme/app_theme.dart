import 'package:flutter/material.dart';

enum AppThemeMode { 
    light, 
    dark, 
    amoled 
}

class AppTheme {
    static ThemeData fromMode(AppThemeMode mode) {
        switch (mode) {
            case AppThemeMode.light: return light;
            case AppThemeMode.dark: return dark;
            case AppThemeMode.amoled: return amoled;
        }
    }

    static ThemeData light = ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF2E7D32), // Forest Green (Trust/Finance)
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        
        cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
            ),
        ),
        textTheme: const TextTheme(
            titleLarge: TextStyle(
                color: Color(0xFF1A1A1A), 
                fontWeight: FontWeight.bold,
                fontSize: 22,
            ),
            bodyLarge: TextStyle(color: Color(0xFF1A1A1A)),
            bodyMedium: TextStyle(color: Color(0xFF757575)),
            labelSmall: TextStyle(
                color: Color(0xFF9E9E9E), 
                fontWeight: FontWeight.bold
            ),
        ),
        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF9F9F9),
            elevation: 0,
            centerTitle: false,
            foregroundColor: Color(0xFF1A1A1A),
        ),
    );

    static ThemeData dark = ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF64B5F6), // Modern Slate Blue
        scaffoldBackgroundColor: const Color(0xFF121416),
        
        cardTheme: CardThemeData(
            color: const Color(0xFF1E2125),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),

        textTheme: const TextTheme(
            titleLarge: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold
            ),
            bodyLarge: TextStyle(color: Color(0xFFE1E1E1)),
            bodyMedium: TextStyle(color: Color(0xFFB0B0B0)),
            labelSmall: TextStyle(
                color: Colors.grey, 
                fontWeight: FontWeight.bold
            ),
        ),

        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF121416),
            elevation: 0,
            foregroundColor: Colors.white,
        ),
    );

    static ThemeData amoled = ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFFCCFF90), // High contrast Lime
        scaffoldBackgroundColor: Colors.black,
        
        cardTheme: CardThemeData(
            color: const Color(0xFF121212), // Very dark grey, almost black
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
        ),

        textTheme: const TextTheme(
            titleLarge: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold
            ),
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.grey),
        ),

        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            elevation: 0,
            foregroundColor: Colors.white,
        ),
    );
}