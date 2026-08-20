import 'package:flutter/material.dart';

const Color cosarcPink = Color(0xFFE91E63);

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String selected = '';

  Widget option(String label, IconData icon) {
    final isSelected = selected == label;
    return GestureDetector(
      onTap: () => setState(() => selected = label),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? cosarcPink : Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
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
          "Tell us about yourself",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "What is your gender?",
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 32),
        option("Male", Icons.male),
        option("Female", Icons.female),
        option("Prefer not to say", Icons.circle_outlined),
      ],
    );
  }
}
