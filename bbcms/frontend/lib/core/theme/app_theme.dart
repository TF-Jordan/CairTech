import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

class BbcTheme {
  BbcTheme._();

  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: BbcColors.ink,
      primary: BbcColors.ink,
      onPrimary: Colors.white,
      surface: BbcColors.surface,
      onSurface: BbcColors.ink,
      error: BbcColors.danger,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: BbcColors.bg,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      textSelectionTheme: const TextSelectionThemeData(cursorColor: BbcColors.ink),
      appBarTheme: AppBarTheme(
        backgroundColor: BbcColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: BbcColors.ink),
        titleTextStyle: BbcTypo.screenTitle(),
        centerTitle: false,
      ),
      dividerColor: BbcColors.hair,
      iconTheme: const IconThemeData(color: BbcColors.ink, size: 18),
      textTheme: TextTheme(
        bodyMedium: BbcTypo.sans(size: 14, color: BbcColors.ink),
        bodySmall: BbcTypo.sans(size: 12, color: BbcColors.muted),
        labelSmall: BbcTypo.mono(size: 10, color: BbcColors.muted),
        titleMedium: BbcTypo.screenTitle(),
        titleLarge: BbcTypo.serif(size: 28),
        headlineSmall: BbcTypo.serif(size: 22),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BbcColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: BbcColors.hair),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: BbcColors.hair),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: BbcColors.ink, width: 1.4),
        ),
        hintStyle: BbcTypo.sans(size: 14, color: BbcColors.muted2),
        labelStyle: BbcTypo.mono(size: 10, color: BbcColors.muted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BbcColors.ink,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          textStyle: BbcTypo.sans(size: 14, weight: FontWeight.w500),
        ),
      ),
    );
  }
}
