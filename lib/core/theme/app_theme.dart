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
    return _build(scheme, Brightness.light, fontFamily);
  }

  static ThemeData dark({String fontFamily = fontMontserrat}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFE07C5C),
      brightness: Brightness.dark,
    );
    return _build(scheme, Brightness.dark, fontFamily);
  }

  static ThemeData _build(
    ColorScheme scheme,
    Brightness brightness,
    String fontFamily,
  ) {
    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
    );

    final textTheme = base.textTheme
        .copyWith(
          displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w100),
          displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w200),
          displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w300),

          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),

          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),

          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w200),

          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w300),
        )
        .apply(fontFamily: fontFamily);
    final primaryTextTheme = base.primaryTextTheme.apply(
      fontFamily: fontFamily,
    );

    TextStyle f({
      double? size,
      FontWeight? weight,
      Color? color,
      double? height,
    }) {
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );
    }

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: primaryTextTheme,

      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        toolbarTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: scheme.surfaceContainerHighest,
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: f(),
        floatingLabelStyle: f(weight: FontWeight.w600),

        hintStyle: f(color: scheme.onSurfaceVariant),
        helperStyle: f(),
        errorStyle: f(color: scheme.error),
        prefixStyle: f(),
        suffixStyle: f(),
        counterStyle: f(),
      ),

      listTileTheme: ListTileThemeData(
        titleTextStyle: textTheme.bodyLarge,
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        leadingAndTrailingTextStyle: textTheme.labelMedium,
      ),

      checkboxTheme: CheckboxThemeData(
        side: BorderSide(color: scheme.outline, width: 1.5),
      ),

      dialogTheme: DialogThemeData(
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: textTheme.bodyMedium,
      ),

      snackBarTheme: SnackBarThemeData(
        contentTextStyle: f(
          color: scheme.onInverseSurface,
          weight: FontWeight.w500,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      tabBarTheme: TabBarThemeData(
        labelStyle: textTheme.titleSmall,
        unselectedLabelStyle: textTheme.titleSmall,
      ),

      chipTheme: ChipThemeData(
        labelStyle: f(weight: FontWeight.w500),
        secondaryLabelStyle: f(weight: FontWeight.w500),
      ),

      tooltipTheme: TooltipThemeData(
        textStyle: f(
          color: brightness == Brightness.dark
              ? scheme.onInverseSurface
              : scheme.onInverseSurface,
        ),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodyMedium,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          labelStyle: f(),
          hintStyle: f(color: scheme.onSurfaceVariant),
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        labelTextStyle: WidgetStatePropertyAll(textTheme.bodyMedium),
      ),

      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: f(weight: FontWeight.w600)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(textStyle: f(weight: FontWeight.w600)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(textStyle: f(weight: FontWeight.w600)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(textStyle: f(weight: FontWeight.w600)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        extendedTextStyle: f(weight: FontWeight.w600),
      ),
    );
  }
}
