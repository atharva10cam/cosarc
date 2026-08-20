import 'package:flutter/material.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import 'cosarc_glass.dart';

/// Shared premium onboarding step layout.
class OnboardingStep extends StatelessWidget {
  const OnboardingStep({
    super.key,
    required this.stepNumber,
    required this.totalSteps,
    required this.overline,
    required this.title,
    required this.subtitle,
    required this.body,
    this.icon,
  });

  final int stepNumber;
  final int totalSteps;
  final String overline;
  final String title;
  final String subtitle;
  final Widget body;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: CosarcSpacing.screenHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: CosarcSpacing.xxl),
          Row(
            children: [
              if (icon != null)
                CosarcGlass(
                  radius: CosarcSpacing.radiusMd,
                  blur: 12,
                  padding: const EdgeInsets.all(CosarcSpacing.md),
                  child: Icon(icon, color: CosarcColors.primary, size: 28),
                ),
              if (icon != null) const SizedBox(width: CosarcSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stepNumber.toString().padLeft(2, '0')} / ${totalSteps.toString().padLeft(2, '0')}',
                      style: CosarcTypography.overline(overline),
                    ),
                    const SizedBox(height: CosarcSpacing.xxs),
                    Text(overline, style: CosarcTypography.caption(context)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: CosarcSpacing.xxxl),
          Text(title,
              style: CosarcTypography.display(context,
                      color: CosarcColors.textPrimary)
                  .copyWith(fontSize: 34)),
          const SizedBox(height: CosarcSpacing.sm),
          Text(subtitle, style: CosarcTypography.body(context)),
          const SizedBox(height: CosarcSpacing.xxxl),
          body,
          const SizedBox(height: CosarcSpacing.huge),
        ],
      ),
    );
  }
}

/// Selectable option card for onboarding choices.
class OnboardingOption extends StatelessWidget {
  const OnboardingOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.description,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CosarcSpacing.sm),
      child: CosarcGlass(
        onTap: onTap,
        highlight: selected,
        padding: const EdgeInsets.all(CosarcSpacing.lg),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected
                      ? CosarcColors.primary.withOpacity(0.2)
                      : CosarcColors.glassFill(0.06),
                  borderRadius: BorderRadius.circular(CosarcSpacing.radiusSm),
                ),
                child: Icon(
                  icon,
                  color: selected
                      ? CosarcColors.primary
                      : CosarcColors.textSecondary,
                ),
              ),
              const SizedBox(width: CosarcSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: selected
                              ? CosarcColors.textPrimary
                              : CosarcColors.textSecondary,
                        ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(description!,
                        style: CosarcTypography.caption(context)),
                  ],
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? CosarcColors.primary
                      : CosarcColors.glassBorder(0.2),
                  width: 2,
                ),
                color: selected ? CosarcColors.primary : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: CosarcColors.ink)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
