import 'package:flutter/material.dart';

const Color cosarcPink = Color(0xFFE91E63);

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  String selected = '';

  Widget goal(String text) {
    final isSelected = selected == text;

    return GestureDetector(
      onTap: () => setState(() => selected = text),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? cosarcPink : Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
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
          "What's your goal?",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        goal("Gain Muscle"),
        goal("Lose Weight"),
        goal("Stay Consistent"),
      ],
    );
  }
}
