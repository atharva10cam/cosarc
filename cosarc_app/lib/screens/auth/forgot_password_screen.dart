import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_button.dart';
import '../../widgets/cosarc/cosarc_input.dart';
import '../../widgets/cosarc/cosarc_scaffold.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _showMessage('Enter a valid email address', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.resetPassword(email);
      setState(() => _sent = true);
      _showMessage('Reset link sent. Check your inbox.');
    } catch (e) {
      _showMessage(_authService.friendlyAuthError(e), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              Text(
                'Reset password',
                style: CosarcTypography.headline(context),
              ),
              const SizedBox(height: CosarcSpacing.sm),
              Text(
                _sent
                    ? 'We sent a secure link to your email. Open it to choose a new password.'
                    : 'Enter your email and we\'ll send a secure reset link.',
                style: CosarcTypography.body(context),
              ),
              const SizedBox(height: CosarcSpacing.xxl),
              if (!_sent) ...[
                CosarcInput(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: CosarcSpacing.xxl),
                CosarcButton(
                  label: 'Send reset link',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _sendResetLink,
                ),
              ] else ...[
                CosarcButton(
                  label: 'Back to sign in',
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: CosarcSpacing.md),
                TextButton(
                  onPressed: _isLoading ? null : _sendResetLink,
                  child: const Text('Resend link'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
