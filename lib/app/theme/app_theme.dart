import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: AppTypography.bodyFamily,
    scaffoldBackgroundColor: AppColors.canvas,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      onSurface: AppColors.foreground,
      error: AppColors.error,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.surface,
      titleTextStyle: TextStyle(
        fontFamily: AppTypography.bodyFamily,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.foreground,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.accent),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.accent, width: 2),
      ),
      hintStyle: TextStyle(color: AppColors.secondary),
    ),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.accent),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.surface,
      contentTextStyle: TextStyle(
        fontFamily: AppTypography.bodyFamily,
        color: AppColors.foreground,
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
