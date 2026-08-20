import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_button.dart';
import '../../widgets/cosarc/cosarc_input.dart';
import '../../widgets/cosarc/cosarc_scaffold.dart';
import '../dashboard/dashboard_root.dart';
import '../onboarding/onboarding_wrapper.dart';

class MfaChallengeScreen extends StatefulWidget {
  const MfaChallengeScreen({super.key});

  @override
  State<MfaChallengeScreen> createState() => _MfaChallengeScreenState();
}

class _MfaChallengeScreenState extends State<MfaChallengeScreen> {
  final _authService = AuthService();
  final _codeController = TextEditingController();
  String? _factorId;
  bool _loading = true;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    _loadFactor();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadFactor() async {
    try {
      final factors = await _authService.listMfaFactors();
      final verified =
          factors.totp.where((f) => f.status.toString().contains('verified'));
      if (verified.isNotEmpty) {
        _factorId = verified.first.id;
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _verify() async {
    if (_factorId == null) {
      _showError('No verified authenticator found.');
      return;
    }

    setState(() => _verifying = true);
    try {
      await _authService.verifyMfaChallenge(
        factorId: _factorId!,
        code: _codeController.text.trim(),
      );
      await _routeAfterAuth();
    } catch (e) {
      _showError(_authService.friendlyAuthError(e));
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _routeAfterAuth() async {
    final needsOnboarding = await _authService.needsOnboarding();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            needsOnboarding ? const OnboardingWrapper() : const DashboardRoot(),
      ),
      (route) => false,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: CosarcColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CosarcScaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: CosarcSpacing.screenHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: CosarcSpacing.huge),
                    Text(
                      'Two-factor authentication',
                      style: CosarcTypography.headline(context),
                    ),
                    const SizedBox(height: CosarcSpacing.sm),
                    Text(
                      'Enter the 6-digit code from your authenticator app.',
                      style: CosarcTypography.body(context),
                    ),
                    const SizedBox(height: CosarcSpacing.xxl),
                    CosarcInput(
                      controller: _codeController,
                      label: 'Authentication code',
                      hint: '000000',
                      keyboardType: TextInputType.number,
                      onSubmitted: (_) => _verify(),
                    ),
                    const SizedBox(height: CosarcSpacing.xxl),
                    CosarcButton(
                      label: 'Verify & continue',
                      isLoading: _verifying,
                      onPressed: _verifying ? null : _verify,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
