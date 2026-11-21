import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF090B0F);
  static const Color surface = Color(0xFF151922);
  static const Color surfaceAlt = Color(0xFF1D2430);
  static const Color accent = Color(0xFFEF3340);
  static const Color muted = Color(0xFF9299A8);

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: accent, secondary: Color(0xFFFF626B),
      surface: surface, error: Color(0xFFFF5A5F),
    );
    return ThemeData(
      useMaterial3: true, brightness: Brightness.dark,
      colorScheme: scheme, scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background, foregroundColor: Colors.white,
        centerTitle: false, elevation: 0,
      ),
      cardTheme: CardTheme(
        color: surface, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface, indicatorColor: accent.withOpacity(.18),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
