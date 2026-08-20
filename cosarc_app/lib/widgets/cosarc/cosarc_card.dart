import 'package:flutter/material.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';

/// Frosted surface card used across dashboard and onboarding.
class CosarcCard extends StatelessWidget {
  const CosarcCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.highlight = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color:
          highlight ? CosarcColors.primaryMuted : CosarcColors.glassFill(0.05),
      borderRadius: BorderRadius.circular(CosarcSpacing.radiusXl),
      border: Border.all(
        color: highlight
            ? CosarcColors.primary.withOpacity(0.35)
            : CosarcColors.glassBorder(),
      ),
      boxShadow:
          highlight ? CosarcColors.glow(CosarcColors.primary, 0.1) : null,
    );

    final content = Padding(
      padding: padding ?? const EdgeInsets.all(CosarcSpacing.cardPadding),
      child: child,
    );

    final card = Container(
      margin: margin,
      decoration: decoration,
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(CosarcSpacing.radiusXl),
                splashColor: CosarcColors.primary.withOpacity(0.08),
                highlightColor: CosarcColors.primary.withOpacity(0.04),
                child: content,
              ),
            ),
    );

    return card;
  }
}
