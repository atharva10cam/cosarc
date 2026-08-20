import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_motion.dart';
import '../../core/theme/cosarc_spacing.dart';

class CosarcNavDestination {
  const CosarcNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Floating pill navigation bar — VisionOS-inspired.
class CosarcNavBar extends StatelessWidget {
  const CosarcNavBar({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onTap,
  });

  final List<CosarcNavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        CosarcSpacing.lg,
        0,
        CosarcSpacing.lg,
        bottom > 0 ? bottom - 4 : CosarcSpacing.sm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CosarcSpacing.radiusPill),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: CosarcColors.glassFill(0.08),
              borderRadius: BorderRadius.circular(CosarcSpacing.radiusPill),
              border: Border.all(color: CosarcColors.glassBorder(0.14)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: List.generate(destinations.length, (index) {
                final dest = destinations[index];
                final selected = currentIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: CosarcMotion.medium,
                      curve: CosarcMotion.easeOut,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? CosarcColors.primary.withOpacity(0.14)
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(CosarcSpacing.radiusPill),
                        border: selected
                            ? Border.all(
                                color: CosarcColors.primary.withOpacity(0.35),
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: CosarcMotion.fast,
                            child: Icon(
                              selected ? dest.selectedIcon : dest.icon,
                              key: ValueKey(selected),
                              size: selected ? 22 : 20,
                              color: selected
                                  ? CosarcColors.primary
                                  : CosarcColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dest.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w500,
                              letterSpacing: 0.3,
                              color: selected
                                  ? CosarcColors.primary
                                  : CosarcColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
