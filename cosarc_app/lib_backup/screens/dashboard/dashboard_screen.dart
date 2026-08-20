import 'package:flutter/material.dart';

const Color cosarcPink = Color(0xFFE91E63);

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Widget tile(String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: cosarcPink, size: 40),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("cosarc"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            tile("cosarc\nThe Cosmic Arc", Icons.auto_awesome),
            tile("My Gym", Icons.fitness_center),
            tile("Nutriwave", Icons.restaurant),
            tile("My Profile", Icons.person),
          ],
        ),
      ),
    );
  }
}
