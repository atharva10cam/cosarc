import 'package:flutter/material.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../widgets/cosarc/cosarc_glass.dart';
import '../../widgets/cosarc/onboarding_step.dart';

class ActivityLevelScreen extends StatefulWidget {
  const ActivityLevelScreen({super.key});

  @override
  State<ActivityLevelScreen> createState() => ActivityLevelScreenState();
}

class ActivityLevelScreenState extends State<ActivityLevelScreen> {
  String selected = '';

  Widget _levelCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = selected == title;
    return GestureDetector(
      onTap: () => setState(() => selected = title),
      child: CosarcGlass(
        highlight: isSelected,
        padding: const EdgeInsets.all(CosarcSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isSelected ? null : null, size: 22),
            const SizedBox(height: CosarcSpacing.sm),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStep(
      stepNumber: 5,
      totalSteps: 7,
      overline: 'Activity',
      icon: Icons.directions_run_outlined,
      title: 'How active\nare you?',
      subtitle: 'Your current activity level shapes your daily contract.',
      body: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: CosarcSpacing.sm,
        crossAxisSpacing: CosarcSpacing.sm,
        childAspectRatio: 0.95,
        children: [
          _levelCard(
            title: 'Beginner',
            description: 'Just starting out',
            icon: Icons.eco_outlined,
          ),
          _levelCard(
            title: 'Lightly Active',
            description: 'Occasional workouts',
            icon: Icons.directions_walk_outlined,
          ),
          _levelCard(
            title: 'Moderate',
            description: '3–4 days a week',
            icon: Icons.trending_up_rounded,
          ),
          _levelCard(
            title: 'Very Active',
            description: 'Hard training daily',
            icon: Icons.local_fire_department_outlined,
          ),
        ],
      ),
    );
  }
}
