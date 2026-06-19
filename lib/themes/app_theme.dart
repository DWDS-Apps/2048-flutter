import 'package:flutter/material.dart';

class AppTheme {
  static const Color tile2 = Color(0xFFeee4da);
  static const Color tile4 = Color(0xFFede0c8);
  static const Color tile8 = Color(0xFFf2b179);
  static const Color tile16 = Color(0xFFf59563);
  static const Color tile32 = Color(0xFFf67c5f);
  static const Color tile64 = Color(0xFFf65e3b);
  static const Color tile128 = Color(0xFFedcf72);
  static const Color tile256 = Color(0xFFedcc61);
  static const Color tile512 = Color(0xFFedc850);
  static const Color tile1024 = Color(0xFFedc53f);
  static const Color tile2048 = Color(0xFFedc22e);
  static const Color tileSuper = Color(0xFF3c3a32);

  static const Color lightText = Color(0xFFf9f6f2);
  static const Color darkText = Color(0xFF776e65);

  static const Color boardBackground = Color(0xFFbbada0);
  static const Color cellBackground = Color(0xFFcdc1b4);
  static const Color gameBackground = Color(0xFFfaf8ef);

  static Color tileColor(int? value) {
    return switch (value) {
      2 => tile2,
      4 => tile4,
      8 => tile8,
      16 => tile16,
      32 => tile32,
      64 => tile64,
      128 => tile128,
      256 => tile256,
      512 => tile512,
      1024 => tile1024,
      2048 => tile2048,
      _ when (value ?? 0) > 2048 => tileSuper,
      _ => Colors.transparent,
    };
  }

  static Color tileTextColor(int? value) {
    if (value == null) return Colors.transparent;
    return value <= 4 ? darkText : lightText;
  }

  static double tileFontSize(int? value) {
    return switch (value) {
      null => 0,
      _ when value < 100 => 32.0,
      _ when value < 1000 => 28.0,
      _ when value < 10000 => 22.0,
      _ => 18.0,
    };
  }

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: gameBackground,
    colorScheme: ColorScheme.light(
      primary: boardBackground,
      onPrimary: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: gameBackground,
      foregroundColor: darkText,
      elevation: 0,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1a1a2e),
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFFbbada0),
      onPrimary: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1a1a2e),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}
