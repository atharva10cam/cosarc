import 'package:flutter/material.dart';

const Color cosarcPink = Color(0xFFE91E63);

class HeightWeightScreen extends StatefulWidget {
  const HeightWeightScreen({super.key});

  @override
  State<HeightWeightScreen> createState() => _HeightWeightScreenState();
}

class _HeightWeightScreenState extends State<HeightWeightScreen> {
  bool isFtKg = true;

  final heightController = TextEditingController(text: "5.8");
  final weightController = TextEditingController(text: "70");

  void toggleUnit(bool toFtKg) {
    setState(() {
      final height = double.tryParse(heightController.text) ?? 0;
      final weight = double.tryParse(weightController.text) ?? 0;

      if (toFtKg && !isFtKg) {
        // cm → ft, lbs → kg
        heightController.text = (height / 30.48).toStringAsFixed(1);
        weightController.text = (weight / 2.20462).toStringAsFixed(0);
      } else if (!toFtKg && isFtKg) {
        // ft → cm, kg → lbs
        heightController.text = (height * 30.48).toStringAsFixed(0);
        weightController.text = (weight * 2.20462).toStringAsFixed(0);
      }

      isFtKg = toFtKg;
    });
  }

  Widget inputCard(
    String title,
    TextEditingController controller,
    String unit,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 22),
              decoration: InputDecoration(
                suffixText: unit,
                suffixStyle: const TextStyle(color: Colors.white),
                border: InputBorder.none,
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Your body metrics",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        ToggleButtons(
          isSelected: [isFtKg, !isFtKg],
          borderRadius: BorderRadius.circular(20),
          fillColor: cosarcPink,
          selectedColor: Colors.white,
          color: Colors.white,
          onPressed: (i) => toggleUnit(i == 0),
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text("ft / kg"),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text("cm / lbs"),
            ),
          ],
        ),

        const SizedBox(height: 32),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              inputCard(
                "Height",
                heightController,
                isFtKg ? "ft" : "cm",
                Icons.height,
              ),
              const SizedBox(width: 16),
              inputCard(
                "Weight",
                weightController,
                isFtKg ? "kg" : "lbs",
                Icons.monitor_weight,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
