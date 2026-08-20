import 'package:flutter/material.dart';

const Color cosarcPink = Color(0xFFE91E63);

class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});

  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  String? type;
  final TextEditingController descriptionCtrl = TextEditingController();

  double duration = 30;
  double intensity = 60; // 0–100 (FIXED)

  bool get canSubmit =>
      type != null && descriptionCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Log Workout"),
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title("What did you train?"),
            Wrap(
              spacing: 12,
              children: ["Strength", "Cardio", "Mobility", "Sport"]
                  .map(_typeChip)
                  .toList(),
            ),

            const SizedBox(height: 28),

            _title("What did you do?"),
            TextField(
              controller: descriptionCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Bench, squats, run, drills…",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 28),

            _sliderBlock(
              title: "Duration",
              valueLabel: "${duration.round()} min",
              value: duration,
              min: 5,
              max: 120,
              onChanged: (v) => setState(() => duration = v),
            ),

            const SizedBox(height: 20),

            _sliderBlock(
              title: "Intensity ${intensityEmoji()}",
              valueLabel: intensityLabel(),
              value: intensity,
              min: 0,
              max: 100,
              onChanged: (v) => setState(() => intensity = v),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canSubmit
                    ? () => Navigator.pop(context, true)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canSubmit ? cosarcPink : Colors.white12,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  "Confirm Workout",
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS =================

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      );

  Widget _typeChip(String t) {
    final selected = type == t;
    return ChoiceChip(
      label: Text(t),
      selected: selected,
      onSelected: (_) => setState(() => type = t),
      selectedColor: cosarcPink,
      backgroundColor: Colors.white12,
      labelStyle:
          TextStyle(color: selected ? Colors.white : Colors.white70),
    );
  }

  Widget _sliderBlock({
    required String title,
    required String valueLabel,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(valueLabel,
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          activeColor: cosarcPink,
          inactiveColor: Colors.white24,
          onChanged: onChanged,
        ),
      ],
    );
  }

  String intensityLabel() {
    if (intensity < 30) return "Light";
    if (intensity < 70) return "Moderate";
    return "Brutal";
  }

  String intensityEmoji() {
    if (intensity < 30) return "🧘";
    if (intensity < 70) return "🔥";
    return "💀";
  }
}
