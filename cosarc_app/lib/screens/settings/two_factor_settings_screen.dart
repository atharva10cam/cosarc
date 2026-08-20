import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_button.dart';
import '../../widgets/cosarc/cosarc_glass.dart';
import '../../widgets/cosarc/cosarc_input.dart';
import '../../widgets/cosarc/cosarc_scaffold.dart';
import '../auth/otp_verification_screen.dart';

class TwoFactorSettingsScreen extends StatefulWidget {
  const TwoFactorSettingsScreen({super.key});

  @override
  State<TwoFactorSettingsScreen> createState() =>
      _TwoFactorSettingsScreenState();
}

class _TwoFactorSettingsScreenState extends State<TwoFactorSettingsScreen> {
  final _authService = AuthService();
  final _codeController = TextEditingController();
  bool _loading = true;
  bool _enrolling = false;
  bool _verifying = false;
  bool _hasTotp = false;
  String? _factorId;
  String? _totpSecret;
  String? _qrCode;
  TwoFactorMethod _preferred = TwoFactorMethod.totp;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final factors = await _authService.listMfaFactors();
      final verified =
          factors.totp.where((f) => f.status == FactorStatus.verified);
      _hasTotp = verified.isNotEmpty;
      if (verified.isNotEmpty) _factorId = verified.first.id;
      _preferred = await _authService.getPreferredTwoFactorMethod();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _startTotpEnrollment() async {
    setState(() => _enrolling = true);
    try {
      final response = await _authService.enrollTotp();
      setState(() {
        _factorId = response.id;
        _totpSecret = response.totp.secret;
        _qrCode = response.totp.qrCode;
      });
    } catch (e) {
      _showMessage(_authService.friendlyAuthError(e), isError: true);
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  Future<void> _verifyEnrollment() async {
    if (_factorId == null) return;
    setState(() => _verifying = true);
    try {
      await _authService.verifyTotpEnrollment(
        factorId: _factorId!,
        code: _codeController.text.trim(),
      );
      setState(() {
        _hasTotp = true;
        _totpSecret = null;
        _qrCode = null;
      });
      _codeController.clear();
      _showMessage('Two-factor authentication enabled');
    } catch (e) {
      _showMessage(_authService.friendlyAuthError(e), isError: true);
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _disableTotp() async {
    if (_factorId == null) return;
    try {
      await _authService.unenrollFactor(_factorId!);
      setState(() {
        _hasTotp = false;
        _factorId = null;
      });
      _showMessage('Two-factor authentication disabled');
    } catch (e) {
      _showMessage(_authService.friendlyAuthError(e), isError: true);
    }
  }

  Future<void> _setPreferred(TwoFactorMethod method) async {
    await _authService.setPreferredTwoFactorMethod(method);
    setState(() => _preferred = method);
    _showMessage('Preferred method updated');
  }

  Future<void> _reverifyWithEmail() async {
    final email = _authService.currentUser?.email;
    if (email == null) return;
    await _authService.sendEmailOtp(email, shouldCreateUser: false);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(email: email),
      ),
    );
  }

  Future<void> _reverifyWithSms() async {
    _showMessage(
        'Add your phone in Connected Accounts to use SMS verification.');
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
                    const SizedBox(height: CosarcSpacing.sm),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        Expanded(
                          child: Text(
                            'Two-factor authentication',
                            style: CosarcTypography.headline(context)
                                .copyWith(fontSize: 22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: CosarcSpacing.lg),
                    CosarcGlass(
                      expand: true,
                      highlight: _hasTotp,
                      padding: const EdgeInsets.all(CosarcSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _hasTotp ? '2FA is enabled' : '2FA is off',
                            style: CosarcTypography.title(context),
                          ),
                          const SizedBox(height: CosarcSpacing.xs),
                          Text(
                            _hasTotp
                                ? 'Your account requires a code at sign-in.'
                                : 'Protect your account with authenticator or OTP verification.',
                            style: CosarcTypography.body(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: CosarcSpacing.xl),
                    Text('Preferred method',
                        style: CosarcTypography.title(context)),
                    const SizedBox(height: CosarcSpacing.sm),
                    _MethodTile(
                      title: 'Authenticator app (TOTP)',
                      subtitle: 'Recommended · Supabase MFA',
                      selected: _preferred == TwoFactorMethod.totp,
                      onTap: () => _setPreferred(TwoFactorMethod.totp),
                    ),
                    _MethodTile(
                      title: 'Email OTP',
                      subtitle: 'Re-verify sensitive sessions via email',
                      selected: _preferred == TwoFactorMethod.email,
                      onTap: () => _setPreferred(TwoFactorMethod.email),
                    ),
                    _MethodTile(
                      title: 'SMS OTP',
                      subtitle: 'Re-verify via text message',
                      selected: _preferred == TwoFactorMethod.sms,
                      onTap: () => _setPreferred(TwoFactorMethod.sms),
                    ),
                    const SizedBox(height: CosarcSpacing.xl),
                    if (!_hasTotp && _qrCode == null) ...[
                      CosarcButton(
                        label: 'Set up authenticator',
                        isLoading: _enrolling,
                        onPressed: _enrolling ? null : _startTotpEnrollment,
                      ),
                    ],
                    if (_qrCode != null) ...[
                      CosarcGlass(
                        expand: true,
                        padding: const EdgeInsets.all(CosarcSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Scan QR code',
                                style: CosarcTypography.title(context)),
                            const SizedBox(height: CosarcSpacing.sm),
                            Text(
                              'Use Google Authenticator, 1Password, or Authy.',
                              style: CosarcTypography.caption(context),
                            ),
                            if (_totpSecret != null) ...[
                              const SizedBox(height: CosarcSpacing.md),
                              SelectableText(
                                _totpSecret!,
                                style: CosarcTypography.body(context).copyWith(
                                  fontFamily: 'monospace',
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: _totpSecret!));
                                  _showMessage('Secret copied');
                                },
                                child: const Text('Copy secret'),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: CosarcSpacing.lg),
                      CosarcInput(
                        controller: _codeController,
                        label: 'Verification code',
                        hint: '000000',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: CosarcSpacing.lg),
                      CosarcButton(
                        label: 'Enable 2FA',
                        isLoading: _verifying,
                        onPressed: _verifying ? null : _verifyEnrollment,
                      ),
                    ],
                    if (_hasTotp) ...[
                      CosarcButton(
                        label: 'Disable authenticator 2FA',
                        variant: CosarcButtonVariant.secondary,
                        onPressed: _disableTotp,
                      ),
                    ],
                    const SizedBox(height: CosarcSpacing.xl),
                    Text('Reverify session',
                        style: CosarcTypography.title(context)),
                    const SizedBox(height: CosarcSpacing.sm),
                    CosarcButton(
                      label: 'Send email verification code',
                      variant: CosarcButtonVariant.secondary,
                      onPressed: _reverifyWithEmail,
                    ),
                    const SizedBox(height: CosarcSpacing.sm),
                    CosarcButton(
                      label: 'Send SMS verification code',
                      variant: CosarcButtonVariant.secondary,
                      onPressed: _reverifyWithSms,
                    ),
                    const SizedBox(height: CosarcSpacing.huge),
                  ],
                ),
              ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CosarcSpacing.sm),
      child: CosarcGlass(
        expand: true,
        highlight: selected,
        onTap: onTap,
        padding: const EdgeInsets.all(CosarcSpacing.md),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color:
                  selected ? CosarcColors.primary : CosarcColors.textTertiary,
            ),
            const SizedBox(width: CosarcSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: CosarcTypography.title(context)
                          .copyWith(fontSize: 15)),
                  Text(subtitle, style: CosarcTypography.caption(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
