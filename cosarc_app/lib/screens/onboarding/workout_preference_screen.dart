import 'package:flutter/material.dart';
import '../../widgets/cosarc/onboarding_step.dart';

class WorkoutPreferenceScreen extends StatefulWidget {
  const WorkoutPreferenceScreen({super.key});

  @override
  State<WorkoutPreferenceScreen> createState() =>
      WorkoutPreferenceScreenState();
}

class WorkoutPreferenceScreenState extends State<WorkoutPreferenceScreen> {
  String selected = '';

  @override
  Widget build(BuildContext context) {
    return OnboardingStep(
      stepNumber: 4,
      totalSteps: 7,
      overline: 'Training',
      icon: Icons.fitness_center_outlined,
      title: 'Where do\nyou train?',
      subtitle: 'We will tailor your workout experience to your environment.',
      body: Column(
        children: [
          OnboardingOption(
            label: 'Gym',
            description: 'Full equipment access',
            icon: Icons.fitness_center_rounded,
            selected: selected == 'Gym',
            onTap: () => setState(() => selected = 'Gym'),
          ),
          OnboardingOption(
            label: 'Outdoor Exercises',
            description: 'Fresh air and movement',
            icon: Icons.park_outlined,
            selected: selected == 'Outdoor Exercises',
            onTap: () => setState(() => selected = 'Outdoor Exercises'),
          ),
          OnboardingOption(
            label: 'Home Workout',
            description: 'Train from anywhere',
            icon: Icons.home_outlined,
            selected: selected == 'Home Workout',
            onTap: () => setState(() => selected = 'Home Workout'),
          ),
          OnboardingOption(
            label: 'Sports',
            description: 'Competitive and team-based',
            icon: Icons.sports_rounded,
            selected: selected == 'Sports',
            onTap: () => setState(() => selected = 'Sports'),
          ),
        ],
      ),
    );
  }
}
