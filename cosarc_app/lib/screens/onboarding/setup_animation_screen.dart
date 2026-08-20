import 'package:flutter/material.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_scaffold.dart';
import 'setup_complete_screen.dart';

class SetupAnimationScreen extends StatefulWidget {
  const SetupAnimationScreen({super.key});

  @override
  State<SetupAnimationScreen> createState() => _SetupAnimationScreenState();
}

class _SetupAnimationScreenState extends State<SetupAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SetupCompleteScreen()),
      );
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CosarcScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
              ),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: CosarcColors.primary.withOpacity(0.4)),
                  boxShadow: CosarcColors.glow(CosarcColors.primary, 0.2),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: CosarcColors.primary, size: 32),
              ),
            ),
            const SizedBox(height: CosarcSpacing.xxl),
            Text('Crafting your profile',
                style: CosarcTypography.title(context)),
            const SizedBox(height: CosarcSpacing.xs),
            Text('Just a moment...', style: CosarcTypography.caption(context)),
          ],
        ),
      ),
    );
  }
}
