import 'dart:async';

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

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    this.email,
    this.phone,
    this.onVerified,
  }) : assert(email != null || phone != null);

  final String? email;
  final String? phone;
  final Future<void> Function()? onVerified;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _authService = AuthService();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _resending = false;

  // ── Resend cooldown ──────────────────────────────────────────────────────────
  Timer? _cooldownTimer;
  int _cooldownSeconds = 60;

  @override
  void initState() {
    super.initState();
    // Start the initial cooldown immediately — the code was just sent.
    _startCooldown();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSeconds = 60);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_cooldownSeconds <= 1) {
        t.cancel();
        setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length < 6) {
      _showMessage('Enter the 6-digit code', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.verifyOtp(
        email: widget.email,
        phone: widget.phone,
        token: code,
      );
      _showMessage('Verified successfully');
      if (widget.onVerified != null) {
        await widget.onVerified!();
      } else {
        await _defaultRoute();
      }
    } catch (e) {
      _showMessage(_authService.friendlyAuthError(e), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _defaultRoute() async {
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

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      if (widget.email != null) {
        await _authService.sendEmailOtp(widget.email!);
      } else if (widget.phone != null) {
        await _authService.sendPhoneOtp(widget.phone!);
      }
      _showMessage('New code sent');
    } catch (e) {
      _showMessage(_authService.friendlyAuthError(e), isError: true);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? CosarcColors.error : CosarcColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final destination = widget.email ?? widget.phone ?? '';
    final canResend = !_resending && _cooldownSeconds == 0;

    return CosarcScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
              horizontal: CosarcSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: CosarcSpacing.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              const SizedBox(height: CosarcSpacing.lg),
              Text('Enter code', style: CosarcTypography.headline(context)),
              const SizedBox(height: CosarcSpacing.sm),
              Text(
                'We sent a code to $destination',
                style: CosarcTypography.body(context),
              ),
              const SizedBox(height: CosarcSpacing.xxl),
              CosarcInput(
                controller: _codeController,
                label: 'Verification code',
                hint: '000000',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _verify(),
              ),
              const SizedBox(height: CosarcSpacing.xxl),
              CosarcButton(
                label: 'Verify',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _verify,
              ),
              const SizedBox(height: CosarcSpacing.md),
              TextButton(
                onPressed: canResend
                    ? () async {
                        await _resend();
                        _startCooldown();
                      }
                    : null,
                child: Text(
                  _resending
                      ? 'Sending…'
                      : _cooldownSeconds > 0
                          ? 'Resend in ${_cooldownSeconds}s'
                          : 'Resend code',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
