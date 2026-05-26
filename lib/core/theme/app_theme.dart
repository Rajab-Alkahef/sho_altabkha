import 'package:flutter/material.dart';

class AppTheme {
  static const String fontCairo = 'Cairo';
  static const String fontMontserrat = 'Montserrat';

  /// Picks the font family that fits the active locale.
  static String fontForLocale(Locale locale) {
    return locale.languageCode == 'ar' ? fontCairo : fontMontserrat;
  }

  static ThemeData light({String fontFamily = fontMontserrat}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFE07C5C),
      brightness: Brightness.light,
    );
    return _base(scheme, Brightness.light, fontFamily);
  }

  static ThemeData dark({String fontFamily = fontMontserrat}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFE07C5C),
      brightness: Brightness.dark,
    );
    return _base(scheme, Brightness.dark, fontFamily);
  }

  static ThemeData _base(
    ColorScheme scheme,
    Brightness brightness,
    String fontFamily,
  ) {
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: scheme.surfaceContainerHighest,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
