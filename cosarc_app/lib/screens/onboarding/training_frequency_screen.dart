import 'package:flutter/material.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_glass.dart';
import '../../widgets/cosarc/onboarding_step.dart';

class TrainingFrequencyScreen extends StatefulWidget {
  const TrainingFrequencyScreen({super.key});

  @override
  State<TrainingFrequencyScreen> createState() =>
      TrainingFrequencyScreenState();
}

class TrainingFrequencyScreenState extends State<TrainingFrequencyScreen> {
  double days = 3;

  String getEmoji() {
    if (days <= 2) return '😐';
    if (days <= 4) return '🙂';
    if (days <= 6) return '😄';
    return '🔥';
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStep(
      stepNumber: 6,
      totalSteps: 7,
      overline: 'Frequency',
      icon: Icons.calendar_month_outlined,
      title: 'Training\ndays per week',
      subtitle: 'This helps us plan your weekly streak and recovery.',
      body: CosarcGlass(
        expand: true,
        padding: const EdgeInsets.all(CosarcSpacing.xxl),
        child: Column(
          children: [
            Text(getEmoji(), style: const TextStyle(fontSize: 56)),
            const SizedBox(height: CosarcSpacing.md),
            Text(
              '${days.toInt()}',
              style: CosarcTypography.metric(
                '${days.toInt()}',
                color: CosarcColors.primary,
              ).copyWith(fontSize: 56),
            ),
            Text('days per week', style: CosarcTypography.caption(context)),
            const SizedBox(height: CosarcSpacing.xxl),
            Slider(
              value: days,
              min: 1,
              max: 7,
              divisions: 6,
              onChanged: (v) => setState(() => days = v),
            ),
          ],
        ),
      ),
    );
  }
}
