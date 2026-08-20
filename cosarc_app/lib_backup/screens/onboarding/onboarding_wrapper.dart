import 'package:flutter/material.dart';
import '../../widgets/doodle_background.dart';

import 'gender_screen.dart';
import 'age_screen.dart';
import 'height_weight_screen.dart';
import 'workout_preference_screen.dart';
import 'activity_level_screen.dart';
import 'training_frequency_screen.dart';
import 'goal_screen.dart';
import 'setup_animation_screen.dart'; // <-- IMPORTANT

const Color cosarcPink = Color(0xFFE91E63);

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  int step = 0;

  final List<Widget> screens = const [
    GenderScreen(),
    AgeScreen(),
    HeightWeightScreen(),
    WorkoutPreferenceScreen(),
    ActivityLevelScreen(),
    TrainingFrequencyScreen(),
    GoalScreen(),
  ];

  void next() {
    if (step < screens.length - 1) {
      setState(() => step++);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SetupAnimationScreen(), // <-- CHANGED
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DoodleBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: LinearProgressIndicator(
                  value: (step + 1) / screens.length,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(cosarcPink),
                ),
              ),
              Expanded(child: screens[step]),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cosarcPink,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
