import 'package:flutter/material.dart';

class DjColors {
  const DjColors._();

  static const Color ink = Color(0xFF0E1E2E);
  static const Color muted = Color(0xFF64748B);
  static const Color line = Color(0xFFE5EDF3);
  static const Color wash = Color(0xFFF4F7FA);
  static const Color tint = Color(0xFFE8F1F7);
  static const Color navy = Color(0xFF012A4A);
  static const Color blue = Color(0xFF01497C);
  static const Color sky = Color(0xFF2C7DA0);
  static const Color skySoft = Color(0xFFA9D6E5);
  static const Color amberBg = Color(0xFFFFF6E0);
  static const Color amberLine = Color(0xFFEFD48A);
  static const Color amberInk = Color(0xFF8A5A00);
  static const Color green = Color(0xFF1A7F4E);
  static const Color greenBg = Color(0xFFE6F4EC);
  static const Color errorInk = Color(0xFFB42318);
  static const Color errorBg = Color(0xFFFEF3F2);
  static const Color errorLine = Color(0xFFFECDCA);
}

ThemeData buildDreamJobTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: DjColors.navy,
      brightness: Brightness.light,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: DjColors.ink,
    ),
  );
}
