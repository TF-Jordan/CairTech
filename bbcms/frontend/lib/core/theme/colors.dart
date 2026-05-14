import 'package:flutter/material.dart';

/// BBCMS palette — sober institutional + futurist.
/// Mirrors `bbcms/design/styles.css` design tokens.
class BbcColors {
  BbcColors._();

  static const Color ink = Color(0xFF0B1E4A); // primary — deep navy
  static const Color ink2 = Color(0xFF14306B); // secondary
  static const Color muted = Color(0xFF6B7385); // tertiary text
  static const Color muted2 = Color(0xFF9AA0B0); // quaternary
  static const Color hair = Color(0xFFE7E8EE); // hairline
  static const Color hair2 = Color(0xFFF0F1F5); // softer hairline
  static const Color bg = Color(0xFFF6F5F1); // warm cream canvas
  static const Color surface = Color(0xFFFFFFFF); // primary surface
  static const Color surface2 = Color(0xFFFAF9F5); // recessed
  static const Color accent = Color(0xFF2A5FFF); // azure for highlights
  static const Color accentSoft = Color(0xFFE6EDFF);
  static const Color gold = Color(0xFFB89456); // sacred serif accent
  static const Color positive = Color(0xFF2F6B4A);
  static const Color warn = Color(0xFFB8732A);
  static const Color danger = Color(0xFFB84035);

  // Tag tints
  static const Color tagSuccessBg = Color(0xFFECF3EE);
  static const Color tagSuccessBorder = Color(0xFFD6E4DC);
  static const Color tagWarnBg = Color(0xFFF8EEDF);
  static const Color tagWarnBorder = Color(0xFFECDFC7);
}
