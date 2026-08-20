import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_button.dart';
import '../../widgets/cosarc/cosarc_glass.dart';
import '../../widgets/cosarc/cosarc_input.dart';
import '../../widgets/cosarc/cosarc_scaffold.dart';
import 'two_factor_settings_screen.dart';
import '../../core/supabase_config.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final _authService = AuthService();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _changingPassword = false;
  bool _loggingOutEverywhere = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty) {
      _showMessage('Please enter your current password', isError: true);
      return;
    }
    if (_newPasswordController.text.length < 6) {
      _showMessage('Password must be at least 6 characters', isError: true);
      return;
    }

    setState(() => _changingPassword = true);
    try {
      final email = _authService.currentUser?.email;
      if (email == null) throw Exception('No email found for current user');

      try {
        await supabase.auth.signInWithPassword(
          email: email,
          password: _currentPasswordController.text,
        );
      } catch (e) {
        _showMessage('Incorrect current password', isError: true);
        return;
      }

      await _authService.updatePassword(_newPasswordController.text);
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _showMessage('Password updated');
    } catch (e) {
      _showMessage(_authService.friendlyAuthError(e), isError: true);
    } finally {
      if (mounted) setState(() => _changingPassword = false);
    }
  }

  Future<void> _logoutEverywhere() async {
    setState(() => _loggingOutEverywhere = true);
    try {
      await _authService.signOut(everywhere: true);
      if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      _showMessage(_authService.friendlyAuthError(e), isError: true);
    } finally {
      if (mounted) setState(() => _loggingOutEverywhere = false);
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
    final email = _authService.currentUser?.email ?? 'Not available';

    return CosarcScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
              horizontal: CosarcSpacing.screenHorizontal),
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
                  Text('Security', style: CosarcTypography.headline(context)),
                ],
              ),
              const SizedBox(height: CosarcSpacing.xl),
              CosarcGlass(
                expand: true,
                padding: const EdgeInsets.all(CosarcSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Signed in as',
                        style: CosarcTypography.caption(context)),
                    const SizedBox(height: CosarcSpacing.xxs),
                    Text(email, style: CosarcTypography.title(context)),
                  ],
                ),
              ),
              const SizedBox(height: CosarcSpacing.lg),
              CosarcGlass(
                expand: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TwoFactorSettingsScreen(),
                  ),
                ),
                padding: const EdgeInsets.all(CosarcSpacing.lg),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_outlined,
                        color: CosarcColors.primary),
                    const SizedBox(width: CosarcSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Two-factor authentication',
                              style: CosarcTypography.title(context)),
                          Text(
                            'Add an extra layer of protection',
                            style: CosarcTypography.caption(context),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: CosarcColors.textTertiary),
                  ],
                ),
              ),
              const SizedBox(height: CosarcSpacing.xl),
              Text('Change password', style: CosarcTypography.title(context)),
              const SizedBox(height: CosarcSpacing.md),
              CosarcInput(
                controller: _currentPasswordController,
                label: 'Current password',
                hint: '••••••••',
                obscureText: true,
              ),
              const SizedBox(height: CosarcSpacing.md),
              CosarcInput(
                controller: _newPasswordController,
                label: 'New password',
                hint: '••••••••',
                obscureText: true,
              ),
              const SizedBox(height: CosarcSpacing.lg),
              CosarcButton(
                label: 'Update password',
                isLoading: _changingPassword,
                onPressed: _changingPassword ? null : _changePassword,
              ),
              const SizedBox(height: CosarcSpacing.xxl),
              CosarcButton(
                label: 'Sign out everywhere',
                variant: CosarcButtonVariant.secondary,
                icon: Icons.logout_rounded,
                isLoading: _loggingOutEverywhere,
                onPressed: _loggingOutEverywhere ? null : _logoutEverywhere,
              ),
              const SizedBox(height: CosarcSpacing.sm),
              Text(
                'This ends all active sessions on every device.',
                textAlign: TextAlign.center,
                style: CosarcTypography.caption(context),
              ),
              const SizedBox(height: CosarcSpacing.huge),
            ],
          ),
        ),
      ),
    );
  }
}
