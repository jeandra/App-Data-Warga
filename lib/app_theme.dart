import 'package:flutter/material.dart';

/// Palet LUNA dari desain FigCraft: aqua, teal, dan navy.
class AppColors {
  const AppColors._();

  static const primary = Color(0xFF26658C);
  static const primaryDark = Color(0xFF023859);
  static const deep = Color(0xFF011C40);
  static const accent = Color(0xFF54ACBF);
  static const highlight = Color(0xFFA7EBF2);

  static const canvas = Color(0xFFEFF8FA);
  static const page = Color(0xFFE6F3F7);
  static const textDark = deep;
  static const muted = Color(0xFF4F7C93);
  static const line = Color(0xFFCFE7EC);
  static const light = Color(0xFFDDF2F6);
  static const chipMuted = Color(0xFF4F7C93);
  static const navMuted = Color(0xFF7FA8BC);
  static const softBlue = highlight;
  static const paleBlue = Color(0xFFD3EEF3);

  /// Awal & akhir gradient kartu utama.
  static const heroStart = Color(0xFF26658C);
  static const heroEnd = Color(0xFF011C40);
}

class AppShadows {
  const AppShadows._();

  static const card = [
    BoxShadow(color: Color(0x0F011C40), blurRadius: 12, offset: Offset(0, 4)),
  ];
  static const row = [
    BoxShadow(color: Color(0x0D011C40), blurRadius: 12, offset: Offset(0, 4)),
  ];
  static const hero = [
    BoxShadow(color: Color(0x38023859), blurRadius: 24, offset: Offset(0, 10)),
  ];
  static const floating = [
    BoxShadow(color: Color(0x24011C40), blurRadius: 24, offset: Offset(0, 10)),
  ];
  static const accent = [
    BoxShadow(color: Color(0x6654ACBF), blurRadius: 18, offset: Offset(0, 8)),
  ];
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.canvas,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(primary: AppColors.primary, surface: Colors.white),
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.textDark,
      displayColor: AppColors.textDark,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.deep,
      contentTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        color: Colors.white,
      ),
    ),
  );
}
