import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// Type stack
/// - Geist (sans) → UI body & headings
/// - Instrument Serif → editorial moments, large numerals
/// - Geist Mono → eyebrows, timestamps, tags
class BbcTypo {
  BbcTypo._();

  static TextStyle sans({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double letterSpacing = -0.07,
    double? height,
  }) =>
      GoogleFonts.inter(
        // Fallback to Inter; Geist is visually very close to Inter.
        // If a Geist family is added as asset later, swap textStyle accordingly.
        textStyle: TextStyle(
          fontSize: size,
          fontWeight: weight,
          color: color ?? BbcColors.ink,
          letterSpacing: letterSpacing,
          height: height,
        ),
      );

  static TextStyle serif({
    double size = 22,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double letterSpacing = -0.4,
    double? height,
  }) =>
      GoogleFonts.cormorantGaramond(
        textStyle: TextStyle(
          fontSize: size,
          fontWeight: weight,
          color: color ?? BbcColors.ink,
          letterSpacing: letterSpacing,
          height: height ?? 1.05,
        ),
      );

  static TextStyle mono({
    double size = 10,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double letterSpacing = 1.6,
  }) =>
      GoogleFonts.jetBrainsMono(
        textStyle: TextStyle(
          fontSize: size,
          fontWeight: weight,
          color: color ?? BbcColors.muted,
          letterSpacing: letterSpacing,
        ),
      );

  static TextStyle eyebrow({Color? color}) => mono(
        size: 10,
        weight: FontWeight.w500,
        color: color ?? BbcColors.muted,
      );

  static TextStyle screenTitle({Color? color}) =>
      sans(size: 22, weight: FontWeight.w500, color: color, letterSpacing: -0.33);

  static TextStyle metricLarge({Color? color}) =>
      serif(size: 64, weight: FontWeight.w400, color: color, letterSpacing: -1.9, height: 0.95);

  static TextStyle bodyM({Color? color}) =>
      sans(size: 13.5, weight: FontWeight.w500, color: color);

  static TextStyle meta({Color? color}) =>
      sans(size: 11, weight: FontWeight.w400, color: color ?? BbcColors.muted);
}
