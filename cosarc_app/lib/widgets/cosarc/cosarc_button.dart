import 'package:flutter/material.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';

/// Primary action button with optional loading state.
class CosarcButton extends StatelessWidget {
  const CosarcButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = CosarcButtonVariant.primary,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final CosarcButtonVariant variant;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    Color loadingColor = CosarcColors.ink;
    if (variant == CosarcButtonVariant.secondary ||
        variant == CosarcButtonVariant.ghost) {
      loadingColor = CosarcColors.textPrimary;
    } else if (variant == CosarcButtonVariant.destructive) {
      loadingColor = CosarcColors.error;
    }

    final child = isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: loadingColor,
            ),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: CosarcSpacing.xs),
              ],
              Text(label),
            ],
          );

    final style = switch (variant) {
      CosarcButtonVariant.primary => ElevatedButton.styleFrom(
          backgroundColor: CosarcColors.primary,
          foregroundColor: CosarcColors.ink,
          disabledBackgroundColor: CosarcColors.surfaceHighlight,
          disabledForegroundColor: CosarcColors.textDisabled,
        ),
      CosarcButtonVariant.secondary => ElevatedButton.styleFrom(
          backgroundColor: CosarcColors.glassFill(0.1),
          foregroundColor: CosarcColors.textPrimary,
          disabledBackgroundColor: CosarcColors.surface,
          disabledForegroundColor: CosarcColors.textDisabled,
          elevation: 0,
          side: BorderSide(color: CosarcColors.glassBorder(0.2)),
        ),
      CosarcButtonVariant.ghost => ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: CosarcColors.primaryLight,
          disabledForegroundColor: CosarcColors.textDisabled,
          elevation: 0,
        ),
      CosarcButtonVariant.destructive => ElevatedButton.styleFrom(
          backgroundColor: CosarcColors.error.withOpacity(0.15),
          foregroundColor: CosarcColors.error,
          disabledBackgroundColor: CosarcColors.surface,
          disabledForegroundColor: CosarcColors.textDisabled,
          elevation: 0,
          side: BorderSide(color: CosarcColors.error.withOpacity(0.3)),
        ),
    };

    final button = ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: style.copyWith(
        minimumSize: MaterialStatePropertyAll(
          Size(expand ? double.infinity : 0, CosarcSpacing.buttonHeight),
        ),
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CosarcSpacing.radiusPill),
          ),
        ),
      ),
      child: child,
    );

    if (variant != CosarcButtonVariant.primary || !enabled) {
      return button;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CosarcSpacing.radiusPill),
        boxShadow: CosarcColors.glow(CosarcColors.primary, 0.25),
      ),
      child: button,
    );
  }
}

enum CosarcButtonVariant { primary, secondary, ghost, destructive }
