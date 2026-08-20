import 'package:flutter/material.dart';

import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_button.dart';
import '../../widgets/cosarc/cosarc_scaffold.dart';
import '../../widgets/cosarc/cosarc_glass.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CosarcScaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: CosarcSpacing.screenHorizontal,
            vertical: CosarcSpacing.xl,
          ),
          physics: const BouncingScrollPhysics(),
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Text('Help & Support', style: CosarcTypography.headline(context)),
            ],
          ),
          const SizedBox(height: CosarcSpacing.xl),
          Text(
            'Frequently Asked Questions',
            style: CosarcTypography.title(context),
          ),
          const SizedBox(height: CosarcSpacing.md),
          CosarcGlass(
            padding: EdgeInsets.zero,
            child: Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: Column(
                children: [
                  ExpansionTile(
                    title: Text(
                      'How to log a workout?',
                      style: CosarcTypography.body(context)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          CosarcSpacing.lg,
                          0,
                          CosarcSpacing.lg,
                          CosarcSpacing.md,
                        ),
                        child: Text(
                          'Tap the large plus button on the dashboard or go to the "Log Workout" tab to start tracking your session.',
                          style: CosarcTypography.caption(context)
                              .copyWith(color: CosarcColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 1, color: CosarcColors.glassBorder(0.1)),
                  ExpansionTile(
                    title: Text(
                      'How are streaks calculated?',
                      style: CosarcTypography.body(context)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          CosarcSpacing.lg,
                          0,
                          CosarcSpacing.lg,
                          CosarcSpacing.md,
                        ),
                        child: Text(
                          'Streaks are increased by 1 for each consecutive day you log a workout. If you miss a day, the streak resets to zero.',
                          style: CosarcTypography.caption(context)
                              .copyWith(color: CosarcColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 1, color: CosarcColors.glassBorder(0.1)),
                  ExpansionTile(
                    title: Text(
                      'Can I edit a logged workout?',
                      style: CosarcTypography.body(context)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          CosarcSpacing.lg,
                          0,
                          CosarcSpacing.lg,
                          CosarcSpacing.md,
                        ),
                        child: Text(
                          'Currently, workouts cannot be edited once saved. You will need to delete the incorrect log and create a new one.',
                          style: CosarcTypography.caption(context)
                              .copyWith(color: CosarcColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: CosarcSpacing.xxl),
          Text(
            'Need more help?',
            style: CosarcTypography.title(context),
          ),
          const SizedBox(height: CosarcSpacing.md),
          CosarcGlass(
            padding: const EdgeInsets.all(CosarcSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'If you have encountered a bug or need further assistance, please contact us.',
                  style: CosarcTypography.body(context)
                      .copyWith(color: CosarcColors.textSecondary),
                ),
                const SizedBox(height: CosarcSpacing.lg),
                CosarcButton(
                  label: 'Contact Us',
                  icon: Icons.email_outlined,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email client opened...'),
                        backgroundColor: CosarcColors.primary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: CosarcSpacing.xl),
        ],
      ),
      ),
    );
  }
}
