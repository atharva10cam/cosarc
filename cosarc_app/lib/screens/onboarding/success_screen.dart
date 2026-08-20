import 'package:flutter/material.dart';
import '../dashboard/dashboard_root.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardRoot()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosarcColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(CosarcSpacing.lg),
              decoration: const BoxDecoration(
                color: CosarcColors.primaryMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 64,
                color: CosarcColors.primary,
              ),
            ),
            const SizedBox(height: CosarcSpacing.lg),
            Text(
              "You're all set!",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: CosarcSpacing.xs),
            Text(
              '3 months > 1 perfect week',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
