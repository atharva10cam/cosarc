import 'package:flutter/material.dart';
import '../../widgets/cosarc/onboarding_step.dart';

class GenderScreen extends StatefulWidget {
  final void Function(String gender)? onChanged;
  const GenderScreen({super.key, this.onChanged});

  @override
  State<GenderScreen> createState() => GenderScreenState();
}

class GenderScreenState extends State<GenderScreen> {
  String selected = '';

  @override
  Widget build(BuildContext context) {
    return OnboardingStep(
      stepNumber: 1,
      totalSteps: 7,
      overline: 'Identity',
      icon: Icons.person_outline_rounded,
      title: 'Tell us\nabout you',
      subtitle: 'This helps us personalize your training and nutrition plan.',
      body: Column(
        children: [
          OnboardingOption(
            label: 'Male',
            icon: Icons.male_rounded,
            selected: selected == 'Male',
            onTap: () {
              setState(() => selected = 'Male');
              widget.onChanged?.call('Male');
            },
          ),
          OnboardingOption(
            label: 'Female',
            icon: Icons.female_rounded,
            selected: selected == 'Female',
            onTap: () {
              setState(() => selected = 'Female');
              widget.onChanged?.call('Female');
            },
          ),
          OnboardingOption(
            label: 'Prefer not to say',
            icon: Icons.circle_outlined,
            selected: selected == 'Prefer not to say',
            onTap: () {
              setState(() => selected = 'Prefer not to say');
              widget.onChanged?.call('Prefer not to say');
            },
          ),
        ],
      ),
    );
  }
}
