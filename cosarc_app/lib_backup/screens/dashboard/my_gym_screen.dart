import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class MyGymScreen extends StatefulWidget {
  const MyGymScreen({super.key});
  @override
  State<MyGymScreen> createState() => _MyGymScreenState();
}

class _MyGymScreenState extends State<MyGymScreen> {
  UnityWidgetController? _unityWidgetController;
  final Set<String> _selectedMuscles = {};
  final TextEditingController _textController = TextEditingController();
  final Color darkPink = Color.fromARGB(255, 117, 116, 117);
  final List<String> _muscleGroups = [
    "Abs",
    "Arms",
    "Back",
    "Chest",
    "Legs",
    "Shoulders",
    "Traps"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // FULL SCREEN UNITY (Background is now INSIDE Unity)
          Positioned.fill(
            child: UnityWidget(
              onUnityCreated: (c) => _unityWidgetController = c,
              useAndroidViewSurface: true,
            ),
          ),

          // UI OVERLAY
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: _muscleGroups.map((m) {
                      bool isSel = _selectedMuscles.contains(m);
                      return GestureDetector(
                        onTap: () {
                          setState(() => isSel
                              ? _selectedMuscles.remove(m)
                              : _selectedMuscles.add(m));
                          _unityWidgetController?.postMessage(
                              'FlutterCommunication',
                              'SelectMuscles',
                              _selectedMuscles.join(","));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel ? darkPink : Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: isSel ? darkPink : Colors.white24),
                          ),
                          child: Text(m.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _textController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter notes...",
                      filled: true,
                      fillColor: Color.fromARGB(209, 255, 255, 255),
                      prefixIcon: Icon(Icons.edit, color: darkPink),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
