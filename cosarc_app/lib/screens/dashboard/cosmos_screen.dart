import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../widgets/dynamic_island_streak.dart';
import '../../widgets/cosarc/cosarc_glass.dart';
import '../../widgets/cosarc/cosarc_section.dart';
import '../../services/auth_service.dart';
import '../../core/supabase_config.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import 'workout_log_screen.dart';
import 'enhanced_nutrition_screen.dart';
import 'profile_screen.dart';
import '../../models/food_log.dart';

class CosmosScreen extends StatefulWidget {
  const CosmosScreen({super.key});

  @override
  State<CosmosScreen> createState() => _CosmosScreenState();
}

class _CosmosScreenState extends State<CosmosScreen> {
  final _authService = AuthService();
  String? _memberId;
  Map<String, dynamic>? _todayContract;
  Map<String, dynamic>? _streakData;
  bool _isLoading = true;

  static const int waterTarget = 3000;
  static const int stepTarget = 10000;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      _memberId = await _authService.getMemberId();
      if (_memberId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final today = DateTime.now().toIso8601String().split('T')[0];
      var contract = await supabase
          .from('daily_contracts')
          .select()
          .eq('member_id', _memberId!)
          .eq('contract_date', today)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      // Upsert is safe against duplicate-insert races (unique constraint on member_id, contract_date)
      await supabase.from('daily_contracts').upsert(
        {'member_id': _memberId, 'contract_date': today},
        onConflict: 'member_id,contract_date',
        ignoreDuplicates: true,
      ).timeout(const Duration(seconds: 10));
      contract = await supabase
          .from('daily_contracts')
          .select()
          .eq('member_id', _memberId!)
          .eq('contract_date', today)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      var streak = await supabase
          .from('streaks')
          .select()
          .eq('member_id', _memberId!)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      // Upsert is safe against duplicate-insert races (streaks unique on member_id)
      await supabase.from('streaks').upsert(
        {'member_id': _memberId},
        onConflict: 'member_id',
        ignoreDuplicates: true,
      ).timeout(const Duration(seconds: 10));
      streak = await supabase
          .from('streaks')
          .select()
          .eq('member_id', _memberId!)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      if (mounted) {
        setState(() {
          _todayContract = contract;
          _streakData = streak;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isFoodLoggedToday(Box<FoodLog> box) {
    if (_todayContract?['nutrition_logged'] == true) return true;
    final today = DateTime.now();
    return box.values.any(
      (log) =>
          log.dateTime.year == today.year &&
          log.dateTime.month == today.month &&
          log.dateTime.day == today.day,
    );
  }

  bool get _contractComplete {
    final box = Hive.box<FoodLog>('daily_logs');
    return (_todayContract?['workout_completed'] ?? false) &&
        _isFoodLoggedToday(box) &&
        ((_todayContract?['water_intake_ml'] ?? 0) >= waterTarget) &&
        ((_todayContract?['steps_count'] ?? 0) >= stepTarget);
  }

  bool get workoutDone => _todayContract?['workout_completed'] ?? false;
  int get waterMl => _todayContract?['water_intake_ml'] ?? 0;
  int get steps => _todayContract?['steps_count'] ?? 0;
  int get currentStreak => _streakData?['current_streak'] ?? 0;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  int _completedCount(bool eatCleanDone) {
    var count = 0;
    if (workoutDone) count++;
    if (eatCleanDone) count++;
    if (waterMl >= waterTarget) count++;
    if (steps >= stepTarget) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return ValueListenableBuilder(
      valueListenable: Hive.box<FoodLog>('daily_logs').listenable(),
      builder: (context, Box<FoodLog> box, _) {
        final eatCleanDone = _isFoodLoggedToday(box);
        final completed = _completedCount(eatCleanDone);
        final progress = completed / 4;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        CosarcSpacing.screenHorizontal,
                        topInset + 56,
                        CosarcSpacing.screenHorizontal,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_greeting,
                                        style:
                                            CosarcTypography.caption(context)),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Command\nCenter',
                                      style: CosarcTypography.display(context)
                                          .copyWith(fontSize: 36),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const ProfileScreen()),
                                ),
                                child: const CosarcGlass(
                                  radius: CosarcSpacing.radiusPill,
                                  blur: 12,
                                  padding: EdgeInsets.all(12),
                                  child: Icon(
                                      Icons.person_outline_rounded,
                                      size: 22),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: CosarcSpacing.xxl),
                          _HeroProgressRing(
                            progress: progress,
                            completed: completed,
                            total: 4,
                            isComplete: _contractComplete,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                      child: CosarcSectionHeader(
                    overline: 'Daily Contract',
                    title: "Today's commitments",
                    subtitle: '$completed of 4 complete',
                  )),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: CosarcSpacing.screenHorizontal),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: CosarcSpacing.sm,
                        crossAxisSpacing: CosarcSpacing.sm,
                        childAspectRatio: 0.92,
                      ),
                      delegate: SliverChildListDelegate([
                        _ContractTile(
                          title: 'Workout',
                          subtitle: workoutDone ? 'Logged' : 'Tap to log',
                          icon: Icons.fitness_center_rounded,
                          completed: workoutDone,
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const WorkoutLogScreen()),
                            );
                            if (result == true) await _loadData();
                          },
                        ),
                        _ContractTile(
                          title: 'Fuel',
                          subtitle: eatCleanDone ? 'Logged' : 'Log nutrition',
                          icon: Icons.restaurant_rounded,
                          completed: eatCleanDone,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const EnhancedNutritionScreen()),
                          ),
                        ),
                        _ProgressTile(
                          title: 'Water',
                          value: '$waterMl ml',
                          target: '3L goal',
                          progress: (waterMl / waterTarget).clamp(0.0, 1.0),
                          icon: Icons.water_drop_outlined,
                          actionLabel: '+300ml',
                          onAction: waterMl >= waterTarget
                              ? null
                              : () async {
                                  if (_isLoading || _todayContract == null) {
                                    return;
                                  }
                                  try {
                                    await supabase
                                        .from('daily_contracts')
                                        .update(
                                            {'water_intake_ml': waterMl + 300})
                                        .eq('id', _todayContract!['id'])
                                        .timeout(const Duration(seconds: 10));
                                    await _loadData();
                                  } catch (e) {
                                    debugPrint('Error updating water: $e');
                                  }
                                },
                        ),
                        _ProgressTile(
                          title: 'Steps',
                          value: '$steps',
                          target: '$stepTarget goal',
                          progress: (steps / stepTarget).clamp(0.0, 1.0),
                          icon: Icons.directions_walk_rounded,
                        ),
                      ]),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(CosarcSpacing.screenHorizontal),
                      child: CosarcGlass(
                        highlight: _contractComplete,
                        expand: true,
                        child: Column(
                          children: [
                            Icon(
                              _contractComplete
                                  ? Icons.auto_awesome_rounded
                                  : Icons.lock_outline_rounded,
                              color: _contractComplete
                                  ? CosarcColors.primary
                                  : CosarcColors.textTertiary,
                              size: 28,
                            ),
                            const SizedBox(height: CosarcSpacing.md),
                            Text(
                              _contractComplete
                                  ? 'Reflection unlocked'
                                  : 'Complete all four to unlock reflection',
                              textAlign: TextAlign.center,
                              style: CosarcTypography.title(context)
                                  .copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: CosarcSpacing.xxs),
                            Text(
                              _contractComplete
                                  ? 'You showed up today. That is the work.'
                                  : '${4 - completed} remaining',
                              textAlign: TextAlign.center,
                              style: CosarcTypography.caption(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
              Positioned(
                top: topInset + 8,
                left: 0,
                right: 0,
                child:
                    Center(child: DynamicIslandStreak(streak: currentStreak)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroProgressRing extends StatelessWidget {
  const _HeroProgressRing({
    required this.progress,
    required this.completed,
    required this.total,
    required this.isComplete,
  });

  final double progress;
  final int completed;
  final int total;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    return CosarcGlass(
      expand: true,
      padding: const EdgeInsets.all(CosarcSpacing.xxl),
      highlight: isComplete,
      child: Row(
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 88,
                  height: 88,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: CosarcColors.glassFill(0.12),
                    valueColor: AlwaysStoppedAnimation(
                      isComplete ? CosarcColors.accent : CosarcColors.primary,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: CosarcTypography.metric('').copyWith(fontSize: 22),
                ),
              ],
            ),
          ),
          const SizedBox(width: CosarcSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DAILY CONTRACT', style: CosarcTypography.overline('')),
                const SizedBox(height: CosarcSpacing.xs),
                Text(
                  isComplete ? 'Contract fulfilled' : 'In progress',
                  style: CosarcTypography.title(context),
                ),
                const SizedBox(height: CosarcSpacing.xxs),
                Text(
                  '$completed of $total pillars complete today',
                  style: CosarcTypography.caption(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContractTile extends StatelessWidget {
  const _ContractTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.completed,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CosarcGlass(
      onTap: onTap,
      highlight: completed,
      padding: const EdgeInsets.all(CosarcSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon,
                  color: completed
                      ? CosarcColors.primary
                      : CosarcColors.textSecondary,
                  size: 24),
              Icon(
                completed
                    ? Icons.check_circle_rounded
                    : Icons.arrow_outward_rounded,
                size: 18,
                color: completed
                    ? CosarcColors.primary
                    : CosarcColors.textTertiary,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      CosarcTypography.title(context).copyWith(fontSize: 17)),
              const SizedBox(height: 2),
              Text(subtitle, style: CosarcTypography.caption(context)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressTile extends StatelessWidget {
  const _ProgressTile({
    required this.title,
    required this.value,
    required this.target,
    required this.progress,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String value;
  final String target;
  final double progress;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final done = progress >= 1.0;
    return CosarcGlass(
      highlight: done,
      padding: const EdgeInsets.all(CosarcSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 22,
                  color:
                      done ? CosarcColors.primary : CosarcColors.textSecondary),
              const Spacer(),
              if (actionLabel != null && onAction != null && !done)
                GestureDetector(
                  onTap: onAction,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: CosarcColors.primaryMuted,
                      borderRadius:
                          BorderRadius.circular(CosarcSpacing.radiusPill),
                      border: Border.all(
                          color: CosarcColors.primary.withOpacity(0.3)),
                    ),
                    child: Text(
                      actionLabel!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: CosarcColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      CosarcTypography.title(context).copyWith(fontSize: 17)),
              Text(value, style: CosarcTypography.caption(context)),
              const SizedBox(height: CosarcSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: CosarcColors.glassFill(0.12),
                  valueColor: AlwaysStoppedAnimation(
                    done ? CosarcColors.accent : CosarcColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(target,
                  style:
                      CosarcTypography.caption(context).copyWith(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
