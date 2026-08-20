import 'package:flutter/material.dart';

const Color cosarcPink = Color(0xFFE91E63);

class TrainingFrequencyScreen extends StatefulWidget {
  const TrainingFrequencyScreen({super.key});

  @override
  State<TrainingFrequencyScreen> createState() =>
      _TrainingFrequencyScreenState();
}

class _TrainingFrequencyScreenState extends State<TrainingFrequencyScreen> {
  double days = 3;

  String getEmoji() {
    if (days == 0) return "😞";
    if (days <= 2) return "😐";
    if (days <= 4) return "🙂";
    if (days <= 6) return "😄";
    return "🔥";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "How often will you train?",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            getEmoji(),
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 12),
          Text(
            "${days.toInt()} days",
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Slider(
            value: days,
            min: 0,
            max: 7,
            divisions: 7,
            activeColor: cosarcPink,
            onChanged: (v) => setState(() => days = v),
          ),
          const Text(
            "This helps us plan your weekly streak",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
