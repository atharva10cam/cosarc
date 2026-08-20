import 'package:flutter/material.dart';

const Color cosarcPink = Color(0xFFE91E63);

class WorkoutPreferenceScreen extends StatefulWidget {
  const WorkoutPreferenceScreen({super.key});

  @override
  State<WorkoutPreferenceScreen> createState() =>
      _WorkoutPreferenceScreenState();
}

class _WorkoutPreferenceScreenState extends State<WorkoutPreferenceScreen> {
  String selected = '';

  Widget option(String text, IconData icon) {
    final isSelected = selected == text;
    return GestureDetector(
      onTap: () => setState(() => selected = text),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? cosarcPink : Colors.white12,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 16),
            Text(text, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Workout preference",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        option("Gym", Icons.fitness_center),
        option("Outdoor Exercises", Icons.nature),
        option("Home Workout", Icons.home),
        option("Sports", Icons.sports),
      ],
    );
  }
}
