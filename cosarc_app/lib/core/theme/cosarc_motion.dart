import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Motion tokens — Apple-grade spring physics and easing.
abstract final class CosarcMotion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 520);
  static const Duration hero = Duration(milliseconds: 680);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve spring = Curves.easeOutBack;

  static const SpringDescription islandSpring =
      SpringDescription(mass: 1, stiffness: 300, damping: 28);

  static const SpringDescription softSpring =
      SpringDescription(mass: 1, stiffness: 220, damping: 24);

  static const SpringDescription snappySpring =
      SpringDescription(mass: 0.8, stiffness: 400, damping: 26);

  static void animateSpring(
    AnimationController controller, {
    required bool expand,
    SpringDescription spring = islandSpring,
  }) {
    controller.animateWith(
      SpringSimulation(spring, controller.value, expand ? 1.0 : 0.0, 0.0),
    );
  }
}
