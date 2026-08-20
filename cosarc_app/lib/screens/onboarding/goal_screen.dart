import 'package:flutter/material.dart';
import '../../widgets/cosarc/onboarding_step.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => GoalScreenState();
}

class GoalScreenState extends State<GoalScreen> {
  String selected = '';

  @override
  Widget build(BuildContext context) {
    return OnboardingStep(
      stepNumber: 7,
      totalSteps: 7,
      overline: 'Goal',
      icon: Icons.flag_outlined,
      title: "What's your\nprimary goal?",
      subtitle: 'Your north star — we will align every metric to this.',
      body: Column(
        children: [
          OnboardingOption(
            label: 'Gain Muscle',
            description: 'Build strength and size',
            icon: Icons.fitness_center_rounded,
            selected: selected == 'Gain Muscle',
            onTap: () => setState(() => selected = 'Gain Muscle'),
          ),
          OnboardingOption(
            label: 'Lose Weight',
            description: 'Lean out and feel lighter',
            icon: Icons.trending_down_rounded,
            selected: selected == 'Lose Weight',
            onTap: () => setState(() => selected = 'Lose Weight'),
          ),
          OnboardingOption(
            label: 'Stay Consistent',
            description: 'Build unbreakable habits',
            icon: Icons.auto_graph_rounded,
            selected: selected == 'Stay Consistent',
            onTap: () => setState(() => selected = 'Stay Consistent'),
          ),
        ],
      ),
    );
  }
}
