import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../core/supabase_config.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_button.dart';
import '../../widgets/cosarc/cosarc_glass.dart';
import '../../widgets/cosarc/cosarc_loader.dart';
import '../../widgets/cosarc/cosarc_section.dart';
import '../auth/login_screen.dart';
import '../settings/appearance_settings_screen.dart';
import '../settings/edit_profile_screen.dart';
import '../settings/help_support_screen.dart';
import '../settings/notifications_settings_screen.dart';
import '../settings/security_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  Map<String, dynamic>? _memberData;
  Map<String, dynamic>? _streakData;
  int _thisMonthWorkouts = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final memberId = await _authService.getMemberId();
      if (memberId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final member = await supabase
          .from('members')
          .select()
          .eq('id', memberId)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      final streak = await supabase
          .from('streaks')
          .select()
          .eq('member_id', memberId)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      // Count this month's workouts from workout_logs
      final now = DateTime.now();
      final firstOfMonth =
          DateTime(now.year, now.month, 1).toIso8601String().split('T')[0];
      final wlResponse = await supabase
          .from('workout_logs')
          .select('id')
          .eq('member_id', memberId)
          .gte('created_at', firstOfMonth)
          .timeout(const Duration(seconds: 10));
      final monthCount = (wlResponse as List).length;

      if (mounted) {
        setState(() {
          _memberData = member;
          _streakData = streak;
          _thisMonthWorkouts = monthCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  String _getDisplayValue(dynamic value, String defaultValue) {
    if (value == null || value.toString().isEmpty) {
      return defaultValue;
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: CosarcLoader(message: 'Loading profile…'),
      );
    }

    // Extract data with fallbacks
    final name = _getDisplayValue(_memberData?['name'], 'Fitness Warrior');
    final email = _getDisplayValue(_memberData?['email'], 'warrior@cosarc.app');
    final currentStreak = _streakData?['current_streak'] ?? 0;
    final longestStreak = _streakData?['longest_streak'] ?? 0;
    final thisMonthWorkouts = _thisMonthWorkouts;

    // Onboarding data
    final age = _memberData?['age'] ?? 0;
    final height = _memberData?['height'] ?? 0.0;
    final weight = _memberData?['weight'] ?? 0.0;
    final gender = _getDisplayValue(_memberData?['gender'], 'Not set');
    final fitnessGoal =
        _getDisplayValue(_memberData?['fitness_goal'], 'Not set');
    final workoutPreference =
        _getDisplayValue(_memberData?['workout_preference'], 'Not set');
    final activityLevel =
        _getDisplayValue(_memberData?['activity_level'], 'Not set');
    final trainingFrequency = _memberData?['training_frequency'] ?? 0;

    final topInset = MediaQuery.of(context).padding.top;
    final hasActiveStreak = currentStreak > 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                CosarcSpacing.screenHorizontal,
                topInset + CosarcSpacing.sm,
                CosarcSpacing.screenHorizontal,
                0,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CosarcGlass(
                        onTap: () => Navigator.pop(context),
                        radius: CosarcSpacing.radiusPill,
                        blur: 12,
                        padding: const EdgeInsets.all(CosarcSpacing.sm),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: CosarcColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'IDENTITY',
                        style: CosarcTypography.overline(''),
                      ),
                    ],
                  ),
                  const SizedBox(height: CosarcSpacing.xxl),
                  _ProfileAvatar(name: name),
                  const SizedBox(height: CosarcSpacing.lg),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: CosarcTypography.headline(context),
                  ),
                  const SizedBox(height: CosarcSpacing.xxs),
                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: CosarcTypography.caption(context),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: CosarcSpacing.xxl)),

          // Achievement presentation
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CosarcSpacing.screenHorizontal,
              ),
              child: CosarcGlass(
                expand: true,
                highlight: hasActiveStreak,
                padding: const EdgeInsets.all(CosarcSpacing.xl),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: hasActiveStreak
                            ? CosarcColors.brandSweep
                            : LinearGradient(
                                colors: [
                                  CosarcColors.glassFill(0.1),
                                  CosarcColors.glassFill(0.05),
                                ],
                              ),
                        boxShadow: hasActiveStreak
                            ? CosarcColors.glow(CosarcColors.primary, 0.2)
                            : null,
                      ),
                      child: Icon(
                        hasActiveStreak
                            ? Icons.local_fire_department_rounded
                            : Icons.emoji_events_outlined,
                        color: hasActiveStreak
                            ? CosarcColors.ink
                            : CosarcColors.textTertiary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: CosarcSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasActiveStreak
                                ? '$currentStreak-day streak'
                                : 'Start your streak',
                            style: CosarcTypography.title(context),
                          ),
                          const SizedBox(height: CosarcSpacing.xxs),
                          Text(
                            longestStreak > 0
                                ? 'Personal best · $longestStreak days'
                                : 'Complete daily contracts to build momentum',
                            style: CosarcTypography.caption(context),
                          ),
                        ],
                      ),
                    ),
                    if (longestStreak > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.emoji_events_rounded,
                            color: CosarcColors.primary,
                            size: 20,
                          ),
                          const SizedBox(height: CosarcSpacing.xxs),
                          Text(
                            '$longestStreak',
                            style: CosarcTypography.metric(
                              longestStreak.toString(),
                              color: CosarcColors.primary,
                            ).copyWith(fontSize: 22),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: CosarcSpacing.lg)),

          // Glass stat modules
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CosarcSpacing.screenHorizontal,
              ),
              child: CosarcGlass(
                expand: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: CosarcSpacing.lg,
                  vertical: CosarcSpacing.xl,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CosarcMetricTile(
                        label: 'Streak',
                        value: currentStreak.toString(),
                        icon: Icons.local_fire_department_rounded,
                        accent: CosarcColors.warning,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 48,
                      color: CosarcColors.divider,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: CosarcSpacing.md),
                        child: CosarcMetricTile(
                          label: 'Workouts',
                          value: thisMonthWorkouts.toString(),
                          icon: Icons.fitness_center_rounded,
                          accent: CosarcColors.primary,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 48,
                      color: CosarcColors.divider,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: CosarcSpacing.md),
                        child: CosarcMetricTile(
                          label: 'Best',
                          value: longestStreak.toString(),
                          icon: Icons.emoji_events_rounded,
                          accent: CosarcColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: CosarcSectionHeader(
              overline: 'About you',
              title: 'Personal Information',
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CosarcSpacing.screenHorizontal,
              ),
              child: CosarcGlass(
                expand: true,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Gender',
                      value: gender,
                    ),
                    const _SectionDivider(),
                    _InfoRow(
                      icon: Icons.cake_rounded,
                      label: 'Age',
                      value: age > 0 ? '$age years' : 'Not set',
                    ),
                    const _SectionDivider(),
                    _InfoRow(
                      icon: Icons.height_rounded,
                      label: 'Height',
                      value: height > 0
                          ? '${height.toStringAsFixed(1)} cm'
                          : 'Not set',
                    ),
                    const _SectionDivider(),
                    _InfoRow(
                      icon: Icons.monitor_weight_rounded,
                      label: 'Weight',
                      value: weight > 0
                          ? '${weight.toStringAsFixed(1)} kg'
                          : 'Not set',
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: CosarcSectionHeader(
              overline: 'Training',
              title: 'Fitness Profile',
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CosarcSpacing.screenHorizontal,
              ),
              child: CosarcGlass(
                expand: true,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.flag_rounded,
                      label: 'Fitness Goal',
                      value: fitnessGoal,
                    ),
                    const _SectionDivider(),
                    _InfoRow(
                      icon: Icons.fitness_center_rounded,
                      label: 'Workout Preference',
                      value: workoutPreference,
                    ),
                    const _SectionDivider(),
                    _InfoRow(
                      icon: Icons.speed_rounded,
                      label: 'Activity Level',
                      value: activityLevel,
                    ),
                    const _SectionDivider(),
                    _InfoRow(
                      icon: Icons.calendar_month_rounded,
                      label: 'Training Frequency',
                      value: trainingFrequency > 0
                          ? '$trainingFrequency days/week'
                          : 'Not set',
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: CosarcSectionHeader(
              overline: 'Account',
              title: 'Settings',
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CosarcSpacing.screenHorizontal,
              ),
              child: CosarcGlass(
                expand: true,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsRow(
                      icon: Icons.edit_rounded,
                      label: 'Edit Profile',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    const _SectionDivider(),
                    _SettingsRow(
                      icon: Icons.notifications_rounded,
                      label: 'Notifications',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsSettingsScreen(),
                          ),
                        );
                      },
                    ),
                    const _SectionDivider(),
                    _SettingsRow(
                      icon: Icons.lock_rounded,
                      label: 'Privacy & Security',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SecuritySettingsScreen(),
                          ),
                        );
                      },
                    ),
                    const _SectionDivider(),
                    _SettingsRow(
                      icon: Icons.palette_rounded,
                      label: 'Appearance',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AppearanceSettingsScreen(),
                          ),
                        );
                      },
                    ),
                    const _SectionDivider(),
                    _SettingsRow(
                      icon: Icons.help_rounded,
                      label: 'Help & Support',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HelpSupportScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                CosarcSpacing.screenHorizontal,
                CosarcSpacing.xl,
                CosarcSpacing.screenHorizontal,
                CosarcSpacing.sm,
              ),
              child: CosarcButton(
                label: 'Sign out',
                icon: Icons.logout_rounded,
                variant: CosarcButtonVariant.secondary,
                onPressed: _logout,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: CosarcSpacing.lg,
                bottom: CosarcSpacing.huge,
              ),
              child: Center(
                child: Text(
                  'Cosarc v1.0.0',
                  style: CosarcTypography.caption(context).copyWith(
                    color: CosarcColors.textDisabled,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: CosarcColors.glow(CosarcColors.primary, 0.25),
          ),
        ),
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: CosarcColors.brandSweep,
            border: Border.all(
              color: CosarcColors.glassBorder(0.25),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              name[0].toUpperCase(),
              style: CosarcTypography.metric(name).copyWith(
                fontSize: 44,
                color: CosarcColors.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CosarcSpacing.lg,
        vertical: CosarcSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CosarcColors.primaryMuted,
              borderRadius: BorderRadius.circular(CosarcSpacing.radiusSm),
            ),
            child: Icon(icon, color: CosarcColors.primary, size: 20),
          ),
          const SizedBox(width: CosarcSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: CosarcTypography.caption(context)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: CosarcTypography.title(context).copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CosarcSpacing.lg,
            vertical: CosarcSpacing.md,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: CosarcColors.textSecondary,
                size: 22,
              ),
              const SizedBox(width: CosarcSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: CosarcTypography.body(context).copyWith(
                    color: CosarcColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: CosarcColors.textTertiary,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: CosarcSpacing.lg),
      child: Divider(height: 1, color: CosarcColors.divider),
    );
  }
}
