import 'package:flutter/material.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';

class GymEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;

  const GymEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CosarcSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(CosarcSpacing.xl),
              decoration: BoxDecoration(
                color: CosarcColors.surfaceElevated.withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(color: CosarcColors.borderStrong),
                boxShadow: CosarcColors.glow(CosarcColors.primary, 0.1),
              ),
              child: Icon(icon, size: 48, color: CosarcColors.textSecondary),
            ),
            const SizedBox(height: CosarcSpacing.lg),
            Text(title, style: CosarcTypography.title(context)),
            const SizedBox(height: CosarcSpacing.sm),
            Text(
              message,
              style: CosarcTypography.body(context),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: CosarcSpacing.lg),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  backgroundColor: CosarcColors.primary.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: CosarcSpacing.lg, vertical: CosarcSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CosarcSpacing.radiusPill)),
                ),
                child: Text(actionLabel!, style: const TextStyle(color: CosarcColors.primary)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
