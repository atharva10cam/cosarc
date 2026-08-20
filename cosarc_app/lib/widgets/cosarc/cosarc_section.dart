import 'package:flutter/material.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';

class CosarcSectionHeader extends StatelessWidget {
  const CosarcSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.overline,
  });

  final String title;
  final String? subtitle;
  final String? overline;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CosarcSpacing.screenHorizontal,
        CosarcSpacing.lg,
        CosarcSpacing.screenHorizontal,
        CosarcSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (overline != null) ...[
                  Text(overline!, style: CosarcTypography.overline(overline!)),
                  const SizedBox(height: CosarcSpacing.xxs),
                ],
                Text(title, style: CosarcTypography.title(context)),
                if (subtitle != null) ...[
                  const SizedBox(height: CosarcSpacing.xxs),
                  Text(subtitle!, style: CosarcTypography.caption(context)),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class CosarcMetricTile extends StatelessWidget {
  const CosarcMetricTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accent,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? CosarcColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) Icon(icon, size: 16, color: color.withOpacity(0.8)),
        if (icon != null) const SizedBox(height: CosarcSpacing.xs),
        Text(
          label.toUpperCase(),
          style: CosarcTypography.overline(label),
        ),
        const SizedBox(height: CosarcSpacing.xxs),
        Text(value, style: CosarcTypography.metric(value, color: color)),
      ],
    );
  }
}
