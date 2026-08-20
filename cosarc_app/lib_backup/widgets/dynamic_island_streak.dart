import 'package:flutter/material.dart';

class DynamicIslandStreak extends StatefulWidget {
  final int streak;

  const DynamicIslandStreak({
    super.key,
    required this.streak,
  });

  @override
  State<DynamicIslandStreak> createState() => _DynamicIslandStreakState();
}

class _DynamicIslandStreakState extends State<DynamicIslandStreak> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => setState(() => expanded = !expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: expanded ? 30 : 24,
          vertical: expanded ? 20 : 14,
        ),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.lerp(
            BorderRadius.circular(999), // pill
            BorderRadius.circular(22),  // rounded rectangle
            expanded ? 1 : 0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.65),
              blurRadius: 30,
            ),
          ],
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TOP ROW
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${widget.streak}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "day streak",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              if (expanded) ...[
                const SizedBox(height: 14),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 14),
                const Text(
                  "You’re on track",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Keep showing up daily to\nstrengthen your Arc",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
