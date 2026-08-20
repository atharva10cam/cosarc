import 'package:flutter/material.dart';

/// ERP-derived Cosarc design tokens for the mobile app.
abstract final class CosarcColors {
  // Brand
  static const Color primary =
      Color(0xFFE4C371); // A more refined, electric gold
  static const Color primaryLight = Color(0xFFF7DE9B);
  static const Color primaryMuted = Color(0x33E4C371);
  static const Color rose = Color(0xFFFF2E63); // Vibrant WHOOP/Fitness+ pink
  static const Color accent = Color(0xFF00E5FF); // Vibrant neon blue

  // Surfaces
  static const Color background = Color(0xFF000000); // Deep OLED black
  static const Color backgroundElevated = Color(0xFF0A0A0A);
  static const Color surface = Color(0x1AFFFFFF); // VisionOS 10% white glass
  static const Color surfaceElevated = Color(0x26FFFFFF); // 15% white
  static const Color surfaceHighlight = Color(0x33FFFFFF); // 20% white
  static const Color ink = Color(0xFF000000);

  // Text
  static const Color textPrimary =
      Color(0xFFFFFFFF); // Pure high contrast white
  static const Color textSecondary = Color(0x99FFFFFF); // 60% white
  static const Color textTertiary = Color(0x66FFFFFF); // 40% white
  static const Color textDisabled = Color(0x33FFFFFF);

  // Borders & dividers
  static const Color border = Color(0x1AFFFFFF); // 10%
  static const Color borderStrong = Color(0x26FFFFFF); // 15%
  static const Color divider = Color(0x1AFFFFFF);

  // Semantic
  static const Color success = Color(0xFF34D399); // Electric green
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFF60A5FA);
  static const Color protein = Color(0xFF60A5FA);
  static const Color carbs = Color(0xFFFBBF24);
  static const Color fat = Color(0xFFC084FC);

  static const Gradient appBackgroundGradient = RadialGradient(
    center: Alignment(-0.85, -1.05),
    radius: 1.6,
    colors: [
      Color(0x33E4C371), // Soft gold glow
      Color(0x00000000), // Fade to true black
    ],
  );

  static const Gradient brandSweep = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );

  static const Gradient roseSweep = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [rose, Color(0xFFB0123C)],
  );

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
      ];

  static List<BoxShadow> glow(Color color, [double opacity = 0.25]) => [
        BoxShadow(
          color: color.withOpacity(opacity),
          blurRadius: 32,
          spreadRadius: 8,
          offset: const Offset(0, 12),
        ),
      ];

  // Glass / frosted overlays
  static Color glassFill([double opacity = 0.08]) =>
      Colors.white.withOpacity(opacity);

  static Color glassBorder([double opacity = 0.15]) =>
      Colors.white.withOpacity(opacity);
}

/// Legacy aliases preserve imports across existing screens during migration.
const Color cosarcPink = CosarcColors.primary;
const Color cosarcDark = CosarcColors.background;
const Color cosarcSurface = CosarcColors.surfaceElevated;
const Color cosarcCard = CosarcColors.surfaceHighlight;
const Color cosarcAccent = CosarcColors.accent;
