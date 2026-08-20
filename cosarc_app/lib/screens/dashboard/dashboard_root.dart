import 'package:flutter/material.dart';
import 'cosmos_screen.dart';
import 'my_gym_screen.dart';
import 'nutriwave_screen.dart';
import 'cosarc_ai_screen.dart';
import '../../widgets/cosarc/cosarc_nav_bar.dart';
import '../../widgets/cosarc/cosarc_scaffold.dart';

class DashboardRoot extends StatefulWidget {
  const DashboardRoot({super.key});

  @override
  State<DashboardRoot> createState() => _DashboardRootState();
}

class _DashboardRootState extends State<DashboardRoot> {
  int _currentIndex = 0;

  static const _destinations = [
    CosarcNavDestination(
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome_rounded,
      label: 'Cosmos',
    ),
    CosarcNavDestination(
      icon: Icons.fitness_center_outlined,
      selectedIcon: Icons.fitness_center_rounded,
      label: 'My Gym',
    ),
    CosarcNavDestination(
      icon: Icons.restaurant_outlined,
      selectedIcon: Icons.restaurant_rounded,
      label: 'Nutriwave',
    ),
    CosarcNavDestination(
      icon: Icons.bolt_outlined,
      selectedIcon: Icons.bolt_rounded,
      label: 'AI',
    ),
  ];

  final List<Widget> _screens = const [
    CosmosScreen(),
    MyGymScreen(),
    NutriwaveScreen(),
    CosarcAIScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return CosarcScaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CosarcNavBar(
        destinations: _destinations,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
