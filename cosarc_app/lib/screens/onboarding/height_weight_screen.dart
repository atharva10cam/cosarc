import 'package:flutter/material.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_glass.dart';
import '../../widgets/cosarc/onboarding_step.dart';

class HeightWeightScreen extends StatefulWidget {
  const HeightWeightScreen({super.key});

  @override
  State<HeightWeightScreen> createState() => HeightWeightScreenState();
}

class HeightWeightScreenState extends State<HeightWeightScreen> {
  bool isFtKg = true;
  final heightController = TextEditingController(text: '5.8');
  final weightController = TextEditingController(text: '70');

  void toggleUnit(bool toFtKg) {
    setState(() {
      final height = double.tryParse(heightController.text) ?? 0;
      final weight = double.tryParse(weightController.text) ?? 0;

      if (toFtKg && !isFtKg) {
        heightController.text = (height / 30.48).toStringAsFixed(1);
        weightController.text = (weight / 2.20462).toStringAsFixed(0);
      } else if (!toFtKg && isFtKg) {
        heightController.text = (height * 30.48).toStringAsFixed(0);
        weightController.text = (weight * 2.20462).toStringAsFixed(0);
      }
      isFtKg = toFtKg;
    });
  }

  Widget _metricField(String label, TextEditingController controller,
      String unit, IconData icon) {
    return Expanded(
      child: CosarcGlass(
        padding: const EdgeInsets.all(CosarcSpacing.lg),
        child: Column(
          children: [
            Icon(icon, color: CosarcColors.primary, size: 22),
            const SizedBox(height: CosarcSpacing.sm),
            Text(label.toUpperCase(), style: CosarcTypography.overline(label)),
            const SizedBox(height: CosarcSpacing.sm),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style:
                  CosarcTypography.metric('', color: CosarcColors.textPrimary)
                      .copyWith(fontSize: 28),
              decoration: InputDecoration(
                suffixText: unit,
                suffixStyle: CosarcTypography.caption(context),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStep(
      stepNumber: 3,
      totalSteps: 7,
      overline: 'Metrics',
      icon: Icons.straighten_rounded,
      title: 'Your body\nmetrics',
      subtitle: 'Height and weight power your calorie and macro targets.',
      body: Column(
        children: [
          CosarcGlass(
            expand: true,
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => toggleUnit(true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          vertical: CosarcSpacing.sm),
                      decoration: BoxDecoration(
                        color:
                            isFtKg ? CosarcColors.primary : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(CosarcSpacing.radiusPill),
                      ),
                      child: Text(
                        'ft / kg',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isFtKg
                              ? CosarcColors.ink
                              : CosarcColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => toggleUnit(false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          vertical: CosarcSpacing.sm),
                      decoration: BoxDecoration(
                        color:
                            !isFtKg ? CosarcColors.primary : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(CosarcSpacing.radiusPill),
                      ),
                      child: Text(
                        'cm / lbs',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: !isFtKg
                              ? CosarcColors.ink
                              : CosarcColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: CosarcSpacing.lg),
          Row(
            children: [
              _metricField('Height', heightController, isFtKg ? 'ft' : 'cm',
                  Icons.height_rounded),
              const SizedBox(width: CosarcSpacing.md),
              _metricField('Weight', weightController, isFtKg ? 'kg' : 'lbs',
                  Icons.monitor_weight_outlined),
            ],
          ),
        ],
      ),
    );
  }
}
