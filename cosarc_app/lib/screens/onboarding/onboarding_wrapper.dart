import 'package:flutter/material.dart';
import '../../widgets/cosarc/cosarc_button.dart';
import '../../widgets/cosarc/cosarc_loader.dart';
import '../../widgets/cosarc/cosarc_scaffold.dart';
import '../../services/auth_service.dart';
import '../../core/supabase_config.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_motion.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../domain/onboarding/onboarding_profile.dart';
import 'gender_screen.dart';
import 'age_screen.dart';
import 'height_weight_screen.dart';
import 'workout_preference_screen.dart';
import 'activity_level_screen.dart';
import 'training_frequency_screen.dart';
import 'goal_screen.dart';
import 'setup_animation_screen.dart';

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final _authService = AuthService();
  int step = 0;
  bool _isSaving = false;

  final List<GlobalKey> _screenKeys = List.generate(7, (_) => GlobalKey());
  final List<Widget> screens = [];
  final Map<String, dynamic> _userData = {};

  static const _stepLabels = [
    'Identity',
    'Age',
    'Metrics',
    'Training',
    'Activity',
    'Frequency',
    'Goal',
  ];

  @override
  void initState() {
    super.initState();
    screens.addAll([
      GenderScreen(key: _screenKeys[0]),
      AgeScreen(key: _screenKeys[1]),
      HeightWeightScreen(key: _screenKeys[2]),
      WorkoutPreferenceScreen(key: _screenKeys[3]),
      ActivityLevelScreen(key: _screenKeys[4]),
      TrainingFrequencyScreen(key: _screenKeys[5]),
      GoalScreen(key: _screenKeys[6]),
    ]);
  }

  Future<void> next() async {
    final currentKey = _screenKeys[step];
    final currentState = currentKey.currentState;

    if (currentState != null) {
      switch (step) {
        case 0:
          final genderState = currentState as GenderScreenState;
          if (genderState.selected.isEmpty) {
            _showError('Please select a gender');
            return;
          }
          _userData['gender'] = genderState.selected;
          break;
        case 1:
          final ageState = currentState as AgeScreenState;
          _userData['age'] = ageState.age.toInt();
          break;
        case 2:
          final hwState = currentState as HeightWeightScreenState;
          final height = double.tryParse(hwState.heightController.text) ?? 0;
          final weight = double.tryParse(hwState.weightController.text) ?? 0;
          if (height == 0 || weight == 0) {
            _showError('Please enter valid height and weight');
            return;
          }
          if (hwState.isFtKg) {
            _userData['height'] = (height * 30.48).round().toDouble();
            _userData['weight'] = weight;
          } else {
            _userData['height'] = height;
            _userData['weight'] = (weight / 2.20462).round().toDouble();
          }
          break;
        case 3:
          final prefState = currentState as WorkoutPreferenceScreenState;
          if (prefState.selected.isEmpty) {
            _showError('Please select a workout preference');
            return;
          }
          _userData['workout_preference'] = prefState.selected;
          break;
        case 4:
          final activityState = currentState as ActivityLevelScreenState;
          if (activityState.selected.isEmpty) {
            _showError('Please select an activity level');
            return;
          }
          _userData['activity_level'] = activityState.selected;
          break;
        case 5:
          final freqState = currentState as TrainingFrequencyScreenState;
          _userData['training_frequency'] = freqState.days.toInt();
          break;
        case 6:
          final goalState = currentState as GoalScreenState;
          if (goalState.selected.isEmpty) {
            _showError('Please select a goal');
            return;
          }
          _userData['fitness_goal'] = goalState.selected;
          break;
      }
    }

    debugPrint('Collected onboarding data: $_userData');

    if (step < screens.length - 1) {
      setState(() => step++);
    } else {
      await _completeOnboarding();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: CosarcColors.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isSaving = true);

    try {
      final memberId = await _authService.getMemberId();
      if (memberId == null) throw Exception('No member ID found');

      final payload = OnboardingProfile.sanitize(_userData);
      if (!OnboardingProfile.isComplete(payload)) {
        throw Exception('Please complete every onboarding step.');
      }

      await supabase
          .from('members')
          .update(payload)
          .eq('id', memberId)
          .timeout(const Duration(seconds: 10));

      debugPrint('Onboarding profile saved for member $memberId');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SetupAnimationScreen()),
        );
      }
    } catch (e) {
      debugPrint('Onboarding save error: $e');
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyOnboardingError(e)),
            backgroundColor: CosarcColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  String _friendlyOnboardingError(Object error) {
    final message = error.toString();
    if (message.contains('Could not find') ||
        message.contains('schema cache') ||
        message.contains('column')) {
      return 'Profile setup needs the latest database migration. Please deploy the bundled Supabase migrations and try again.';
    }
    if (message.contains('timeout')) {
      return 'Saving took too long. Check your connection and try again.';
    }
    return 'Could not save your profile. Please review your entries and try again.';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (step + 1) / screens.length;

    return CosarcScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CosarcSpacing.screenHorizontal,
                CosarcSpacing.md,
                CosarcSpacing.screenHorizontal,
                CosarcSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SETUP', style: CosarcTypography.overline('SETUP')),
                  const SizedBox(height: CosarcSpacing.xxs),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _stepLabels[step],
                          style: CosarcTypography.title(context),
                        ),
                      ),
                      Text(
                        '${step + 1}/${screens.length}',
                        style: CosarcTypography.caption(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: CosarcSpacing.md),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(CosarcSpacing.radiusPill),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: CosarcMotion.medium,
                      curve: CosarcMotion.easeOut,
                      builder: (_, value, __) => LinearProgressIndicator(
                        value: value,
                        minHeight: 3,
                        backgroundColor: CosarcColors.glassFill(0.08),
                        valueColor:
                            const AlwaysStoppedAnimation(CosarcColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isSaving
                  ? const CosarcLoader(message: 'Crafting your profile...')
                  : AnimatedSwitcher(
                      duration: CosarcMotion.medium,
                      switchInCurve: CosarcMotion.easeOut,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.04, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: KeyedSubtree(
                        key: ValueKey(step),
                        child: screens[step],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(CosarcSpacing.screenHorizontal),
              child: CosarcButton(
                label:
                    step == screens.length - 1 ? 'Complete Setup' : 'Continue',
                isLoading: _isSaving,
                onPressed: _isSaving ? null : next,
              ),
            ),
            const SizedBox(height: CosarcSpacing.sm),
          ],
        ),
      ),
    );
  }
}
