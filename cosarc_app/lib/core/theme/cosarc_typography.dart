import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cosarc_colors.dart';

/// Editorial typography helpers for Cosarc V2.
abstract final class CosarcTypography {
  static TextStyle display(BuildContext context, {Color? color}) =>
      GoogleFonts.inter(
        fontSize: 42,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.6,
        height: 1.05,
        color: color ?? CosarcColors.textPrimary,
      );

  static TextStyle headline(BuildContext context, {Color? color}) =>
      GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.15,
        color: color ?? CosarcColors.textPrimary,
      );

  static TextStyle title(BuildContext context, {Color? color}) =>
      GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        height: 1.25,
        color: color ?? CosarcColors.textPrimary,
      );

  static TextStyle body(BuildContext context, {Color? color}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color ?? CosarcColors.textSecondary,
      );

  static TextStyle caption(BuildContext context, {Color? color}) =>
      GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color ?? CosarcColors.textTertiary,
      );

  static TextStyle overline(String text, {Color? color}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        color: color ?? CosarcColors.textTertiary,
      );

  static TextStyle metric(String value, {Color? color}) => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
        height: 1,
        color: color ?? CosarcColors.textPrimary,
      );

  static TextStyle brandMark({double size = 26}) => GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w300,
        letterSpacing: 3.2,
        color: CosarcColors.textPrimary,
      );
}
