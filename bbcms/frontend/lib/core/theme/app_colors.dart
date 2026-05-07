import 'package:flutter/material.dart';

/// Light-only color palette inspired by BBCMS plans PDF.
class AppColors {
  const AppColors._();

  // Brand
  static const Color primary = Color(0xFF2563EB); // electric blue (PDF buttons)
  static const Color primaryHover = Color(0xFF1D4ED8);
  static const Color primaryContainer = Color(0xFFDBEAFE);
  static const Color accent = Color(0xFF06B6D4); // cyan glow accent
  static const Color accentSoft = Color(0xFFCFFAFE);

  // Surfaces
  static const Color background = Color(0xFFF5F8FF); // pale blue
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFEEF2FB);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEDF1F7);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softGradient = LinearGradient(
    colors: [Color(0xFFEFF4FF), Color(0xFFE0F2FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
