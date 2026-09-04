import 'package:flutter/material.dart';

class AppTheme {
  static final darkMode = ValueNotifier<bool>(false);

  static Color get ink =>
      darkMode.value ? const Color(0xFFF7F1E8) : const Color(0xFF111111);
  static Color get paper =>
      darkMode.value ? const Color(0xFF191817) : const Color(0xFFFFFCF7);
  static Color get landingBackground =>
      darkMode.value ? const Color(0xFF191817) : paper;
  static const onInk = Color(0xFFFFFCF7);
  static const onYellow = Color(0xFF111111);
  static const beige = Color(0xFFF1E6D2);
  static const yellow = Color(0xFFFFD21F);
  static const pink = Color(0xFFF2447C);
  static const green = Color(0xFF56D839);
  static const lilac = Color(0xFF8665E8);
  static Color get muted =>
      darkMode.value ? const Color(0xFFB9B0A5) : const Color(0xFF6E6B66);

  static void setDarkMode(bool enabled) {
    darkMode.value = enabled;
  }

  static ThemeData light() {
    const inkColor = Color(0xFF111111);
    const paperColor = Color(0xFFFFFCF7);
    final scheme = ColorScheme.fromSeed(
      seedColor: yellow,
      brightness: Brightness.light,
      surface: paperColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: inkColor,
        onPrimary: paperColor,
        secondary: yellow,
        surface: paperColor,
        onSurface: inkColor,
      ),
      scaffoldBackgroundColor: paperColor,
      fontFamily: 'Arial',
      appBarTheme: const AppBarTheme(
        backgroundColor: paperColor,
        foregroundColor: inkColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: Color(0xFF6E6B66)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: inkColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: inkColor, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: inkColor, width: 3),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: yellow,
          foregroundColor: inkColor,
          elevation: 0,
          side: const BorderSide(color: inkColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: inkColor,
          side: const BorderSide(color: inkColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: inkColor, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(color: inkColor, thickness: 1),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: paperColor,
        selectedItemColor: inkColor,
        unselectedItemColor: Color(0xFF6E6B66),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData dark() {
    const darkSurface = Color(0xFF191817);
    const darkCard = Color(0xFF292725);
    const darkInk = Color(0xFFF7F1E8);
    const darkMuted = Color(0xFFB9B0A5);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: yellow,
          brightness: Brightness.dark,
          surface: darkSurface,
        ).copyWith(
          primary: darkInk,
          onPrimary: darkSurface,
          secondary: yellow,
          surface: darkSurface,
          onSurface: darkInk,
        );

    return light().copyWith(
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: darkSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkInk,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        hintStyle: const TextStyle(color: darkMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkInk, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkInk, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkInk, width: 3),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: yellow,
          foregroundColor: const Color(0xFF111111),
          elevation: 0,
          side: const BorderSide(color: darkInk, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkInk,
          side: const BorderSide(color: darkInk, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: darkInk, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(color: darkInk, thickness: 1),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: darkInk,
        unselectedItemColor: darkMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
