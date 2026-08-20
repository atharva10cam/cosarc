import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/app_state.dart';
import '../../core/config/app_config.dart';
import '../../core/supabase_config.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_button.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../dashboard/dashboard_root.dart';
import '../onboarding/onboarding_wrapper.dart';

class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  VideoPlayerController? _controller;
  final AuthService _authService = AuthService();
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final controller = VideoPlayerController.asset(
        'assets/backgrounds/app_intro.mp4',
      );

      await controller.initialize().timeout(const Duration(seconds: 6));

      controller
        ..setVolume(0)
        ..play();

      _controller = controller;
      if (mounted) setState(() {});

      final duration = controller.value.duration;
      final wait =
          duration > Duration.zero && duration < const Duration(seconds: 8)
              ? duration
              : const Duration(seconds: 3);
      Future.delayed(wait, _goNext);
    } catch (e) {
      _controller?.dispose();
      _controller = null;
      Future.delayed(const Duration(seconds: 2), _goNext);
    }
  }

  Future<void> _goNext() async {
    if (!mounted || _navigated) return;
    _navigated = true;
    // Unlock the auth-state listener in main.dart. From this point on,
    // any auth change should drive navigation (splash is done).
    splashNavigationDone = true;

    final configError = AppConfig.configurationError;
    if (configError != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => _ConfigurationErrorScreen(message: configError),
        ),
      );
      return;
    }

    Widget nextScreen = const LoginScreen();

    if (SupabaseConfig.isInitialized && _authService.isLoggedIn) {
      try {
        final needsOnboarding = await _authService
            .needsOnboarding()
            .timeout(const Duration(seconds: 12));
        nextScreen =
            needsOnboarding ? const OnboardingWrapper() : const DashboardRoot();
      } catch (e) {
        debugPrint('Startup routing failed: $e');
      }
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosarcColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            )
          else
            const ColoredBox(color: CosarcColors.background),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  CosarcColors.background.withOpacity(0.85),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: CosarcSpacing.huge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('cosarc', style: CosarcTypography.brandMark(size: 36)),
                    const SizedBox(height: CosarcSpacing.sm),
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: CosarcColors.primary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigurationErrorScreen extends StatelessWidget {
  const _ConfigurationErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosarcColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(CosarcSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(
                Icons.settings_outlined,
                size: 48,
                color: CosarcColors.textTertiary,
              ),
              const SizedBox(height: CosarcSpacing.lg),
              Text(
                'Configuration required',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: CosarcSpacing.sm),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: CosarcSpacing.md),
              Text(
                'Run with:\nflutter run \\\n  --dart-define=SUPABASE_ANON_KEY=your_key',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              CosarcButton(
                label: 'Continue offline to login UI',
                variant: CosarcButtonVariant.secondary,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
