import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/session_preferences.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_button.dart';
import '../../widgets/cosarc/cosarc_glass.dart';
import '../../widgets/cosarc/cosarc_input.dart';
import '../../widgets/cosarc/cosarc_scaffold.dart';
import '../dashboard/dashboard_root.dart';
import '../onboarding/onboarding_wrapper.dart';
import 'auth_carousel.dart';
import 'forgot_password_screen.dart';
import 'mfa_challenge_screen.dart';
import 'otp_verification_screen.dart';
import 'phone_auth_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _useEmailOtp = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  static const _carouselSlides = [
    AuthCarouselSlide(
      title: 'Daily discipline',
      subtitle: 'Complete your contract. Build your streak.',
      icon: Icons.local_fire_department_rounded,
    ),
    AuthCarouselSlide(
      title: 'Train with intention',
      subtitle: 'Log workouts. Track nutrition. Show up.',
      icon: Icons.fitness_center_rounded,
    ),
    AuthCarouselSlide(
      title: 'Premium fitness',
      subtitle: 'Designed for focus, calm, and progress.',
      icon: Icons.auto_awesome_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
    _fadeCtrl.forward();
    _restoreSessionPrefs();
  }

  Future<void> _restoreSessionPrefs() async {
    final remember = await SessionPreferences.instance.rememberMe;
    final email = await SessionPreferences.instance.savedEmail;
    if (mounted) {
      setState(() {
        _rememberMe = remember;
        if (email != null) _emailController.text = email;
      });
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      _showError('Enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_useEmailOtp) {
        try {
          await _authService.sendEmailOtp(email, shouldCreateUser: false);
        } catch (otpErr) {
          final errStr = otpErr.toString().toLowerCase();
          if (errStr.contains('user not found') ||
              errStr.contains('user_not_found')) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'No account found with this email. Please sign up or use a password to continue.',
                ),
                backgroundColor: CosarcColors.error,
                action: SnackBarAction(
                  label: 'Sign up',
                  textColor: Colors.white,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  ),
                ),
              ),
            );
            return;
          }
          rethrow;
        }
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              email: email,
              onVerified: _routeAfterAuth,
            ),
          ),
        );
        return;
      }

      if (_passwordController.text.isEmpty) {
        _showError('Enter your password');
        return;
      }

      await SessionPreferences.instance.setRememberMe(
        enabled: _rememberMe,
        email: email,
      );

      await _authService.signIn(
        email: email,
        password: _passwordController.text,
      );

      if (await _authService.requiresMfaChallenge()) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MfaChallengeScreen()),
        );
        return;
      }

      _showSuccess('Welcome back');
      await _routeAfterAuth();
    } catch (e) {
      _showError(_authService.friendlyAuthError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final success = await _authService.signInWithGoogle();
      if (!success) {
        _showError('Sign-in was cancelled');
        return;
      }
      _showSuccess('Signed in with Google');
      await _routeAfterAuth();
    } catch (e) {
      _showError(_authService.friendlyAuthError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithApple() async {
    setState(() => _isLoading = true);
    try {
      final success = await _authService.signInWithApple();
      if (!success) {
        _showError('Sign-in was cancelled');
        return;
      }
      _showSuccess('Signed in with Apple');
      await _routeAfterAuth();
    } catch (e) {
      _showError(_authService.friendlyAuthError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _routeAfterAuth() async {
    final needsOnboarding = await _authService.needsOnboarding();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            needsOnboarding ? const OnboardingWrapper() : const DashboardRoot(),
      ),
    );
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: CosarcColors.error),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: CosarcColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CosarcScaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: CosarcSpacing.screenHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: CosarcSpacing.lg),
                    Text(
                      'cosarc',
                      textAlign: TextAlign.center,
                      style: CosarcTypography.brandMark(size: 32),
                    ),
                    const SizedBox(height: CosarcSpacing.xl),
                    const AuthCarousel(slides: _carouselSlides),
                    const SizedBox(height: CosarcSpacing.xxl),
                    Text(
                      'Welcome back',
                      style: CosarcTypography.headline(context).copyWith(
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: CosarcSpacing.xs),
                    Text(
                      'Sign in to continue your journey',
                      style: CosarcTypography.body(context),
                    ),
                    const SizedBox(height: CosarcSpacing.xl),
                    CosarcInput(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                    ),
                    if (!_useEmailOtp) ...[
                      const SizedBox(height: CosarcSpacing.lg),
                      CosarcInput(
                        controller: _passwordController,
                        label: 'Password',
                        hint: '••••••••',
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onSubmitted: (_) => _login(),
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: CosarcColors.textTertiary,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ],
                    const SizedBox(height: CosarcSpacing.md),
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: CosarcColors.primary,
                            onChanged: (value) =>
                                setState(() => _rememberMe = value ?? false),
                          ),
                        ),
                        const SizedBox(width: CosarcSpacing.xs),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _rememberMe = !_rememberMe),
                            child: Text(
                              'Remember me',
                              style: CosarcTypography.caption(context),
                            ),
                          ),
                        ),
                        if (!_useEmailOtp)
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ForgotPasswordScreen(
                                  initialEmail: _emailController.text.trim(),
                                ),
                              ),
                            ),
                            child: const Text('Forgot password?'),
                          ),
                      ],
                    ),
                    const SizedBox(height: CosarcSpacing.lg),
                    CosarcGlass(
                      expand: true,
                      onTap: () => setState(() => _useEmailOtp = !_useEmailOtp),
                      padding: const EdgeInsets.symmetric(
                        horizontal: CosarcSpacing.md,
                        vertical: CosarcSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _useEmailOtp
                                ? Icons.mark_email_read_outlined
                                : Icons.password_outlined,
                            color: CosarcColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: CosarcSpacing.sm),
                          Expanded(
                            child: Text(
                              _useEmailOtp
                                  ? 'Using email code · tap for password'
                                  : 'Use email code instead',
                              style: CosarcTypography.caption(context),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: CosarcColors.textTertiary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: CosarcSpacing.xl),
                    CosarcButton(
                      label: _useEmailOtp ? 'Send sign-in code' : 'Sign in',
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _login,
                    ),
                    const SizedBox(height: CosarcSpacing.md),
                    _SocialButton(
                      label: 'Continue with Google',
                      icon: Icons.g_mobiledata_rounded,
                      assetIcon: 'assets/icons/google.png',
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _loginWithGoogle,
                    ),
                    if (_authService.isAppleSignInAvailable) ...[
                      const SizedBox(height: CosarcSpacing.sm),
                      _SocialButton(
                        label: 'Continue with Apple',
                        icon: Icons.apple,
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _loginWithApple,
                      ),
                    ],
                    const SizedBox(height: CosarcSpacing.sm),
                    _SocialButton(
                      label: 'Continue with phone',
                      icon: Icons.phone_iphone_rounded,
                      isLoading: _isLoading,
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PhoneAuthScreen(),
                                ),
                              ),
                    ),
                    const SizedBox(height: CosarcSpacing.xl),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      ),
                      child: Text(
                        'Create an account',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: CosarcColors.textSecondary,
                            ),
                      ),
                    ),
                    const SizedBox(height: CosarcSpacing.xxl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
    this.assetIcon,
  });

  final String label;
  final IconData icon;
  final String? assetIcon;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLoading ? 0.65 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(CosarcSpacing.radiusPill),
          child: Ink(
            height: CosarcSpacing.buttonHeight,
            decoration: BoxDecoration(
              color: CosarcColors.glassFill(0.055),
              borderRadius: BorderRadius.circular(CosarcSpacing.radiusPill),
              border: Border.all(color: CosarcColors.glassBorder()),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (assetIcon != null)
                  Image.asset(
                    assetIcon!,
                    height: 20,
                    width: 20,
                    errorBuilder: (_, __, ___) => Icon(icon, size: 20),
                  )
                else
                  Icon(icon, size: 20),
                const SizedBox(width: CosarcSpacing.sm),
                Text(label, style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
