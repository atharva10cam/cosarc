import 'package:flutter/material.dart';
import '../core/theme/cosarc_colors.dart';

class DoodleBackground extends StatelessWidget {
  final Widget child;

  const DoodleBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: CosarcColors.background,
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: CosarcColors.appBackgroundGradient,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.95, -0.82),
                  radius: 1.2,
                  colors: [
                    CosarcColors.rose.withOpacity(0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/gym_doodles.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.045),
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
