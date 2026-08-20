import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cosarc_colors.dart';
import 'cosarc_spacing.dart';

abstract final class CosarcTheme {
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CosarcColors.background,
      colorScheme: const ColorScheme.dark(
        primary: CosarcColors.primary,
        secondary: CosarcColors.rose,
        surface: CosarcColors.surface,
        error: CosarcColors.error,
        onPrimary: CosarcColors.ink,
        onSecondary: Colors.white,
        onSurface: CosarcColors.textPrimary,
        onError: Colors.white,
      ),
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );

    final inter = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: CosarcColors.textPrimary,
      displayColor: CosarcColors.textPrimary,
    );

    return base.copyWith(
      textTheme: inter.copyWith(
        displayLarge: inter.displayLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
        ),
        displayMedium: inter.displayMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        headlineLarge: inter.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineMedium: inter.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        titleLarge: inter.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleMedium: inter.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: inter.bodyLarge?.copyWith(
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        bodyMedium: inter.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400,
          height: 1.45,
          color: CosarcColors.textSecondary,
        ),
        bodySmall: inter.bodySmall?.copyWith(
          color: CosarcColors.textTertiary,
        ),
        labelLarge: inter.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: CosarcColors.textPrimary,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(
          color: CosarcColors.textPrimary,
          size: 22,
        ),
      ),
      cardTheme: CardTheme(
        color: CosarcColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CosarcSpacing.radiusXl),
          side: BorderSide(color: CosarcColors.glassBorder()),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: CosarcColors.divider,
        thickness: 0.5,
        space: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: CosarcColors.surfaceElevated,
        contentTextStyle: GoogleFonts.inter(
          color: CosarcColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CosarcSpacing.radiusMd),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: CosarcColors.surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CosarcSpacing.radiusXl),
          side: BorderSide(color: CosarcColors.glassBorder(0.15)),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: CosarcColors.textPrimary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: CosarcColors.surfaceElevated,
        modalBackgroundColor: CosarcColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(CosarcSpacing.radiusXl),
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: CosarcColors.primary,
        linearTrackColor: CosarcColors.border,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: CosarcColors.primary,
        inactiveTrackColor: CosarcColors.glassFill(0.12),
        thumbColor: CosarcColors.primaryLight,
        overlayColor: CosarcColors.primaryMuted,
        valueIndicatorColor: CosarcColors.surfaceElevated,
        trackHeight: 5,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CosarcColors.glassFill(0.055),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: CosarcSpacing.lg,
          vertical: CosarcSpacing.md,
        ),
        hintStyle: GoogleFonts.inter(
          color: CosarcColors.textTertiary,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.inter(
          color: CosarcColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CosarcSpacing.radiusMd),
          borderSide: BorderSide(color: CosarcColors.glassBorder()),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CosarcSpacing.radiusMd),
          borderSide: BorderSide(color: CosarcColors.glassBorder()),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CosarcSpacing.radiusMd),
          borderSide: const BorderSide(color: CosarcColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CosarcSpacing.radiusMd),
          borderSide: const BorderSide(color: CosarcColors.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CosarcColors.primary,
          foregroundColor: CosarcColors.ink,
          elevation: 0,
          minimumSize: const Size(double.infinity, CosarcSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: CosarcSpacing.xl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CosarcSpacing.radiusPill),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CosarcColors.primary,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: CosarcColors.textPrimary,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: CosarcSpacing.lg,
          vertical: CosarcSpacing.xxs,
        ),
      ),
    );
  }
}
