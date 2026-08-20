import 'package:flutter/material.dart';
import 'cosmos_screen.dart';
import 'my_gym_screen.dart';
import 'nutriwave_screen.dart';
import 'search_screen.dart';

const Color cosarcPink = Color(0xFFE91E63);

class DashboardRoot extends StatefulWidget {
  const DashboardRoot({super.key});

  @override
  State<DashboardRoot> createState() => _DashboardRootState();
}

class _DashboardRootState extends State<DashboardRoot> {
  int index = 0;

  final pages = const [
    CosmosScreen(),
    MyGymScreen(),
    NutriwaveScreen(),
    SearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌌 GALAXY BACKGROUND (DASHBOARD ONLY)
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/galaxy_bg.jpg', // ✅ FIXED PATH
              fit: BoxFit.cover,
            ),
          ),

          // DARK OVERLAY (READABILITY)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.55),
            ),
          ),

          // CONTENT
          IndexedStack(
            index: index,
            children: pages,
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        backgroundColor: Colors.black.withOpacity(0.85),
        selectedItemColor: cosarcPink,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: 'cosmos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'my gym',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'nutriwave',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'search',
          ),
        ],
      ),
    );
  }
}
