import 'package:flutter/material.dart';

/// Light, refined palette: pure white background + airy blue accents.
class AppColors {
  const AppColors._();

  // Brand
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryHover = Color(0xFF1D4ED8);
  static const Color primaryContainer = Color(0xFFE6EEFE);
  static const Color accent = Color(0xFF60A5FA);
  static const Color accentSoft = Color(0xFFEFF5FF);

  // Surfaces
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF5F8FF);
  static const Color border = Color(0xFFE6ECF5);
  static const Color divider = Color(0xFFEEF2F7);

  // Text
  static const Color textPrimary = Color(0xFF0B1220);
  static const Color textSecondary = Color(0xFF4B5565);
  static const Color textMuted = Color(0xFF98A2B3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF12B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  /// Subtle background gradient — kept for occasional decorative surfaces.
  /// Buttons must NOT use this.
  static const LinearGradient softGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF1F6FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Reserved for hero banners only (kept very subtle).
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFEFF5FF), Color(0xFFE0EBFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
