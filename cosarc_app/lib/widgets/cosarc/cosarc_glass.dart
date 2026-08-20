import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';

/// Frosted glass surface with blur, border, and optional highlight.
class CosarcGlass extends StatelessWidget {
  const CosarcGlass({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.radius = CosarcSpacing.radiusXl,
    this.blur = 24,
    this.opacity = 0.06,
    this.borderOpacity = 0.12,
    this.highlight = false,
    this.expand = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double blur;
  final double opacity;
  final double borderOpacity;
  final bool highlight;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final borderColor = highlight
        ? CosarcColors.primary.withOpacity(0.45)
        : CosarcColors.glassBorder(borderOpacity);

    final fillColor =
        highlight ? CosarcColors.primaryMuted : CosarcColors.glassFill(opacity);

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(CosarcSpacing.cardPadding),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(radius),
            border:
                Border.all(color: borderColor, width: highlight ? 1.5 : 0.5),
            boxShadow: highlight
                ? CosarcColors.glow(CosarcColors.primary, 0.12)
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          splashColor: CosarcColors.primary.withOpacity(0.06),
          highlightColor: CosarcColors.primary.withOpacity(0.03),
          child: content,
        ),
      );
    }

    content = Container(margin: margin, child: content);

    if (expand) {
      return SizedBox(width: double.infinity, child: content);
    }
    return content;
  }
}
