import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_button.dart';
import '../../widgets/cosarc/cosarc_glass.dart';

class NutriwaveScreen extends StatefulWidget {
  const NutriwaveScreen({super.key});

  @override
  State<NutriwaveScreen> createState() => _NutriwaveScreenState();
}

class _NutriwaveScreenState extends State<NutriwaveScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background ambient orb 1
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).size.height * 0.2 +
                    math.sin(_controller.value * 2 * math.pi) * 40,
                left: MediaQuery.of(context).size.width * 0.1 +
                    math.cos(_controller.value * 2 * math.pi) * 40,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        CosarcColors.primary.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: CosarcColors.glow(CosarcColors.primary, 0.2),
                  ),
                ),
              );
            },
          ),
          // Background ambient orb 2
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                bottom: MediaQuery.of(context).size.height * 0.1 +
                    math.cos(_controller.value * 2 * math.pi) * 60,
                right: MediaQuery.of(context).size.width * 0.05 +
                    math.sin(_controller.value * 2 * math.pi) * 60,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        CosarcColors.accent.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: CosarcSpacing.screenHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  // Glass badge
                  Center(
                    child: CosarcGlass(
                      radius: CosarcSpacing.radiusPill,
                      blur: 24,
                      padding: const EdgeInsets.symmetric(
                        horizontal: CosarcSpacing.md,
                        vertical: CosarcSpacing.xs,
                      ),
                      child: Text(
                        'COMING LATE 2026',
                        style: CosarcTypography.overline('COMING LATE 2026')
                            .copyWith(
                          color: CosarcColors.primaryLight,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: CosarcSpacing.xxl),
                  Text(
                    'Precision\nNutrition.',
                    style: CosarcTypography.display(context).copyWith(
                      fontSize: 56,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: CosarcSpacing.xl),
                  Text(
                    'Nutriwave is learning your metabolism.\nSoon, it will craft perfect meals tailored specifically to your biometrics and goals.',
                    style: CosarcTypography.body(context).copyWith(
                      fontSize: 18,
                      color: CosarcColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: CosarcSpacing.xxxl),
                  // Fancy notify button
                  CosarcButton(
                    label: 'Notify Me',
                    icon: Icons.notifications_active_outlined,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('You are on the list.',
                              style: CosarcTypography.body(context)),
                          backgroundColor: CosarcColors.surfaceElevated,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: CosarcSpacing.md),
                  CosarcButton(
                    label: 'Learn More',
                    variant: CosarcButtonVariant.ghost,
                    onPressed: () {},
                  ),
                  const Spacer(flex: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
