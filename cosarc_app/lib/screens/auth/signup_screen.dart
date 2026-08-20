import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_button.dart';
import '../../widgets/cosarc/cosarc_glass.dart';
import '../../widgets/cosarc/cosarc_input.dart';
import '../../widgets/cosarc/cosarc_loader.dart';
import '../../widgets/cosarc/cosarc_scaffold.dart';
import '../onboarding/onboarding_wrapper.dart';
import '../dashboard/dashboard_root.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;
  bool _showEmailForm = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signUpWithEmail() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showError('Please fill all fields');
      return;
    }
    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        onboardingData: null,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingWrapper()),
        );
      }
    } catch (e) {
      _showError(_authService.friendlyAuthError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final success = await _authService.signInWithGoogle();
      if (!success) {
        if (mounted) _showError('Sign-in was cancelled');
        return;
      }
      final needsOnboarding = await _authService.needsOnboarding();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => needsOnboarding
              ? const OnboardingWrapper()
              : const DashboardRoot(),
        ),
      );
    } catch (e) {
      String errorMessage = 'Google sign-in failed. ';
      if (e.toString().contains('DEVELOPER_ERROR')) {
        errorMessage +=
            'Please check SHA-1 configuration in Google Cloud Console.';
      } else if (e.toString().contains('network_error')) {
        errorMessage += 'Please check your internet connection.';
      } else {
        errorMessage += 'Please try again.';
      }
      if (mounted) _showError(errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: CosarcColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CosarcScaffold(
      body: Stack(
        children: [
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: CosarcSpacing.screenHorizontal),
                child:
                    _showEmailForm ? _buildEmailForm() : _buildSocialOptions(),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 4,
            left: 4,
            child: IconButton(
              onPressed: () {
                if (_showEmailForm) {
                  setState(() => _showEmailForm = false);
                } else {
                  Navigator.pop(context);
                }
              },
              icon: const CosarcGlass(
                radius: CosarcSpacing.radiusPill,
                blur: 12,
                padding: EdgeInsets.all(10),
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialOptions() {
    return Column(
      children: [
        const SizedBox(height: 72),
        Text('cosarc', style: CosarcTypography.brandMark(size: 28)),
        const SizedBox(height: CosarcSpacing.xxl),
        Text('Begin your\njourney',
            style: CosarcTypography.display(context).copyWith(fontSize: 36)),
        const SizedBox(height: CosarcSpacing.sm),
        Text('Choose how you would like to continue',
            style: CosarcTypography.body(context)),
        const Spacer(),
        if (_isLoading)
          const CosarcLoader(message: 'Signing you in...')
        else ...[
          CosarcButton(
              label: 'Continue with Google',
              icon: Icons.login_rounded,
              onPressed: _signUpWithGoogle),
          const SizedBox(height: CosarcSpacing.lg),
          Row(
            children: [
              const Expanded(child: Divider(color: CosarcColors.divider)),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: CosarcSpacing.md),
                child: Text('or', style: CosarcTypography.caption(context)),
              ),
              const Expanded(child: Divider(color: CosarcColors.divider)),
            ],
          ),
          const SizedBox(height: CosarcSpacing.lg),
          CosarcButton(
            label: 'Continue with Email',
            variant: CosarcButtonVariant.secondary,
            icon: Icons.mail_outline_rounded,
            onPressed: () => setState(() => _showEmailForm = true),
          ),
        ],
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: CosarcSpacing.xxl),
          child: Text(
            'By continuing, you agree to our Terms & Privacy Policy',
            textAlign: TextAlign.center,
            style: CosarcTypography.caption(context).copyWith(fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 72),
          Text('Create\naccount',
              style: CosarcTypography.display(context).copyWith(fontSize: 34)),
          const SizedBox(height: CosarcSpacing.sm),
          Text('Sign up with your email',
              style: CosarcTypography.body(context)),
          const SizedBox(height: CosarcSpacing.xxxl),
          CosarcInput(
              controller: _nameController,
              label: 'Full name',
              hint: 'Your name'),
          const SizedBox(height: CosarcSpacing.lg),
          CosarcInput(
            controller: _emailController,
            label: 'Email',
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: CosarcSpacing.lg),
          CosarcInput(
            controller: _passwordController,
            label: 'Password',
            hint: 'Min 6 characters',
            obscureText: true,
            onSubmitted: (_) => _signUpWithEmail(),
          ),
          const SizedBox(height: CosarcSpacing.xxl),
          CosarcButton(
            label: 'Create Account',
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _signUpWithEmail,
          ),
          const SizedBox(height: CosarcSpacing.huge),
        ],
      ),
    );
  }
}
