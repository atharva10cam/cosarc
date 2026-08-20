import 'package:flutter/material.dart';

const Color cosarcPink = Color(0xFFE91E63);

class ActivityLevelScreen extends StatefulWidget {
  const ActivityLevelScreen({super.key});

  @override
  State<ActivityLevelScreen> createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  String selected = '';

  Widget block({
    required String title,
    required String description,
  }) {
    final isSelected = selected == title;

    return GestureDetector(
      onTap: () => setState(() => selected = title),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? cosarcPink : Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔝 SCROLLABLE CONTENT
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 16),

                const Text(
                  "How active are you?",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                GridView.count(
                  shrinkWrap: true, // 🔥 IMPORTANT
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    block(
                      title: "Beginner",
                      description: "Just starting out or getting back",
                    ),
                    block(
                      title: "Lightly Active",
                      description: "Occasional workouts or walks",
                    ),
                    block(
                      title: "Moderate",
                      description: "Training 3–4 days a week",
                    ),
                    block(
                      title: "Very Active",
                      description: "Hard training almost daily",
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // 🔽 NOTE:
        // The Continue button is handled by OnboardingWrapper
        // DO NOT add it here
      ],
    );
  }
}
