import 'package:flutter/material.dart';

class DoodleBackground extends StatelessWidget {
  final Widget child;

  const DoodleBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0C0C0C),
        image: DecorationImage(
          image: AssetImage("assets/backgrounds/gym_doodles.png"),
          fit: BoxFit.cover,
          opacity: 0.06,
        ),
      ),
      child: child,
    );
  }
}
