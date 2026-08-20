import 'package:flutter/material.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_glass.dart';
import '../../widgets/cosarc/onboarding_step.dart';

class AgeScreen extends StatefulWidget {
  final void Function(int age)? onChanged;
  const AgeScreen({super.key, this.onChanged});

  @override
  State<AgeScreen> createState() => AgeScreenState();
}

class AgeScreenState extends State<AgeScreen> {
  double age = 25;

  @override
  Widget build(BuildContext context) {
    return OnboardingStep(
      stepNumber: 2,
      totalSteps: 7,
      overline: 'Age',
      icon: Icons.cake_outlined,
      title: 'How old\nare you?',
      subtitle:
          'Age helps us calibrate intensity and recovery recommendations.',
      body: CosarcGlass(
        expand: true,
        padding: const EdgeInsets.all(CosarcSpacing.xxl),
        child: Column(
          children: [
            Text(
              age.toInt().toString(),
              style: CosarcTypography.metric(
                age.toInt().toString(),
                color: CosarcColors.primary,
              ).copyWith(fontSize: 64),
            ),
            Text('years', style: CosarcTypography.caption(context)),
            const SizedBox(height: CosarcSpacing.xxl),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              ),
              child: Slider(
                value: age,
                min: 13,
                max: 100,
                divisions: 87,
                onChanged: (v) {
                  setState(() => age = v);
                  widget.onChanged?.call(v.toInt());
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('13', style: CosarcTypography.caption(context)),
                Text('100', style: CosarcTypography.caption(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
