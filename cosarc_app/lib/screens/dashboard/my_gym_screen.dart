import 'package:flutter/material.dart' hide Badge;

import 'dart:async';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_glass.dart';
import '../../widgets/cosarc/cosarc_section.dart';
import '../../widgets/cosarc/cosarc_button.dart';
import '../../services/auth_service.dart';
import '../../services/gym_service.dart';
import '../../services/notification_service.dart';
import '../../models/gym_models.dart';
import '../../widgets/gym/class_schedule_sheet.dart';
import '../../widgets/gym/trainer_sheet.dart';
import '../../widgets/gym/leaderboard_sheet.dart';
import '../../widgets/gym/gym_empty_state.dart';

class MyGymScreen extends StatefulWidget {
  const MyGymScreen({super.key});

  @override
  State<MyGymScreen> createState() => _MyGymScreenState();
}

class _MyGymScreenState extends State<MyGymScreen> {
  final _authService = AuthService();
  final _gymService = GymService();
  final _notificationService = NotificationService();

  String? _memberId;
  bool _isLoading = true;
  String? _error;

  GymJoinRequest? _joinRequest;
  GymMembership? _membership;
  GymAttendance? _activeSession;
  List<GymAttendance> _attendanceHistory = [];
  List<GymAlert> _alerts = [];
  List<GymChallenge> _challenges = [];
  List<MemberBadge> _memberBadges = [];
  List<ClassBooking> _upcomingClasses = [];
  List<Trainer> _trainers = [];
  
  Timer? _sessionTimer;
  Duration _sessionDuration = Duration.zero;
  
  final _gymCodeController = TextEditingController();
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _notificationService.init();
    _loadData();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _gymCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final memberId = await _authService.getMemberId();
      if (memberId == null) {
        setState(() {
          _error = 'User not found';
          _isLoading = false;
        });
        return;
      }
      _memberId = memberId;



      final joinRequest = await _gymService.getActiveJoinRequest(memberId);
      final membership = await _gymService.getActiveMembership(memberId);
      final activeSession = await _gymService.getActiveSession(memberId);
      final history = await _gymService.getAttendanceHistory(memberId);
      
      List<GymAlert> alerts = [];
      List<GymChallenge> challenges = [];
      List<MemberBadge> badges = [];
      List<ClassBooking> upcomingClasses = [];
      List<Trainer> trainers = [];

      if (membership != null) {
        alerts = await _gymService.getGymAlerts(membership.gymId);
        _notificationService.showMembershipExpiryAlert(membership.daysLeft);
        challenges = await _gymService.getGymChallenges(membership.gymId);
        badges = await _gymService.getMemberBadges(memberId);
        upcomingClasses = await _gymService.getMyClassBookings(memberId, upcoming: true);
        trainers = await _gymService.getTrainers(membership.gymId);
      }

      if (mounted) {
        setState(() {
          _joinRequest = joinRequest;
          _membership = membership;
          _activeSession = activeSession;
          _attendanceHistory = history;
          _alerts = alerts;
          _challenges = challenges;
          _memberBadges = badges;
          _upcomingClasses = upcomingClasses;
          _trainers = trainers;
          _isLoading = false;
        });

        if (_activeSession != null) {
          _startSessionTimer();
        }
      }
    } catch (e, stack) {
      debugPrint('GYM ERROR: $e');
      debugPrint('$stack');

      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    if (_activeSession == null) return;

    _updateDuration();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateDuration();
      }
    });
  }

  void _updateDuration() {
    if (_activeSession == null) return;
    setState(() {
      _sessionDuration = DateTime.now().difference(_activeSession!.checkInTime);
    });
  }

  Future<void> _handleCheckInOut() async {
    if (_memberId == null || _membership == null) return;

    try {
      if (_activeSession == null) {
        final session = await _gymService.checkIn(_memberId!, _membership!.gymId);
        if (mounted) {
          setState(() {
            _activeSession = session;
          });
        }
        _startSessionTimer();
      } else {
        await _gymService.checkOut(_activeSession!.id);
        _sessionTimer?.cancel();
        
        final history = await _gymService.getAttendanceHistory(_memberId!);
        if (mounted) {
          setState(() {
            _activeSession = null;
            _sessionDuration = Duration.zero;
            _attendanceHistory = history;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update session status')),
        );
      }
    }
  }

  Future<void> _handleJoinGym() async {
    final code = _gymCodeController.text.trim();
    if (code.isEmpty || _memberId == null) return;

    setState(() {
      _isJoining = true;
    });



    try {
      await _gymService.requestGymJoin(_memberId!, code);
      await _loadData(); 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Join request submitted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid gym code or already requested')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }



  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final isCheckedIn = _activeSession != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. HERO SECTION
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  CosarcSpacing.screenHorizontal,
                  topInset + CosarcSpacing.lg,
                  CosarcSpacing.screenHorizontal,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GYM COMMAND',
                          style: CosarcTypography.overline('GYM COMMAND',
                              color: CosarcColors.primary.withOpacity(0.85)),
                        ),
                        if (_isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: CosarcColors.primary),
                          )
                      ],
                    ),
                    const SizedBox(height: CosarcSpacing.xxs),
                    Text(
                      'My Gym',
                      style: CosarcTypography.display(context).copyWith(fontSize: 36),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: CosarcSpacing.md)),

            // ERROR WARNING CARD (if any)
            if (_error != null)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: CosarcSpacing.screenHorizontal, vertical: CosarcSpacing.sm),
                sliver: SliverToBoxAdapter(
                  child: CosarcGlass(
                    padding: const EdgeInsets.all(CosarcSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: CosarcColors.error),
                        const SizedBox(width: CosarcSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Unable to load gym data', style: CosarcTypography.body(context).copyWith(fontWeight: FontWeight.bold)),
                              Text('Some features may be unavailable.', style: CosarcTypography.caption(context)),
                              const SizedBox(height: CosarcSpacing.sm),
                              CosarcButton(
                                label: 'Retry',
                                onPressed: _loadData,
                                variant: CosarcButtonVariant.secondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 2. JOIN GYM OR ACTIVE CHECK-IN SECTION
            if (_membership == null) ...[
              if (_joinRequest != null && _joinRequest!.requestStatus == 'pending') ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: CosarcSpacing.screenHorizontal, vertical: CosarcSpacing.sm),
                  sliver: SliverToBoxAdapter(
                    child: CosarcGlass(
                      padding: const EdgeInsets.all(CosarcSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.hourglass_top_rounded, color: CosarcColors.warning, size: 48),
                          const SizedBox(height: CosarcSpacing.md),
                          Text('Request Pending', style: CosarcTypography.title(context)),
                          const SizedBox(height: CosarcSpacing.sm),
                          Text(
                            'Your request is being reviewed by the gym administration.',
                            style: CosarcTypography.body(context),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: CosarcSpacing.md),
                          CosarcButton(
                            label: 'Refresh Status',
                            onPressed: _loadData,
                            icon: Icons.refresh_rounded,
                            variant: CosarcButtonVariant.secondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: CosarcSpacing.screenHorizontal, vertical: CosarcSpacing.sm),
                  sliver: SliverToBoxAdapter(
                    child: CosarcGlass(
                      padding: const EdgeInsets.all(CosarcSpacing.xl),
                      child: Column(
                        children: [
                          Text('JOIN YOUR GYM', style: CosarcTypography.overline('JOIN YOUR GYM', color: CosarcColors.primary)),
                          const SizedBox(height: CosarcSpacing.md),
                          Text(
                            'Unlock: ✓ Attendance ✓ Classes ✓ Trainers ✓ Challenges ✓ Leaderboards',
                            style: CosarcTypography.caption(context),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: CosarcSpacing.lg),
                          TextField(
                            controller: _gymCodeController,
                            decoration: InputDecoration(
                              hintText: 'Enter Gym Code',
                              hintStyle: const TextStyle(color: CosarcColors.textTertiary),
                              filled: true,
                              fillColor: CosarcColors.glassFill(0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(CosarcSpacing.radiusSm),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.search_rounded, color: CosarcColors.textTertiary),
                            ),
                            style: const TextStyle(color: CosarcColors.textPrimary),
                          ),
                          const SizedBox(height: CosarcSpacing.md),
                          if (_isJoining)
                            const CircularProgressIndicator(color: CosarcColors.primary)
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                CosarcButton(
                                  label: 'Join via Code',
                                  onPressed: _handleJoinGym,
                                  icon: Icons.arrow_forward_rounded,
                                ),
                                const SizedBox(height: CosarcSpacing.sm),
                                CosarcButton(
                                  label: 'Join via QR',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Camera access required.')),
                                    );
                                  },
                                  icon: Icons.qr_code_scanner_rounded,
                                  variant: CosarcButtonVariant.secondary,
                                ),
                              ],
                            ),
                          const SizedBox(height: CosarcSpacing.sm),
                          CosarcButton(
                            label: 'Search Gym',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Search functionality coming soon.')),
                              );
                            },
                            icon: Icons.search_rounded,
                            variant: CosarcButtonVariant.secondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ] else ...[
              // ACTIVE CHECK IN CARD
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: CosarcSpacing.screenHorizontal, vertical: CosarcSpacing.sm),
                sliver: SliverToBoxAdapter(child: _buildCheckInCard(isCheckedIn)),
              ),
              if (isCheckedIn) ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: CosarcSpacing.screenHorizontal, vertical: CosarcSpacing.sm),
                  sliver: SliverToBoxAdapter(child: _buildSessionStats()),
                ),
              ],
            ],

            // 3. FEATURES PREVIEW / QUICK STATS
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: CosarcSpacing.screenHorizontal, vertical: CosarcSpacing.sm),
              sliver: SliverToBoxAdapter(child: _buildQuickStats()),
            ),
            
            // QUICK ACTION FEATURES GRID
            const SliverToBoxAdapter(
              child: CosarcSectionHeader(
                title: 'Features',
                subtitle: 'Tools to level up your training',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: CosarcSpacing.screenHorizontal),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: CosarcSpacing.sm,
                  crossAxisSpacing: CosarcSpacing.sm,
                  childAspectRatio: 0.92,
                ),
                delegate: SliverChildListDelegate([
                  _buildFeatureCard(
                    icon: Icons.calendar_month_rounded,
                    title: 'Attendance History',
                    subtitle: 'View check-in heatmap',
                    gradient: const LinearGradient(
                      colors: [CosarcColors.info, Color(0xFF1976D2)],
                    ),
                    onTap: _showAttendanceHistory,
                  ),
                  _buildFeatureCard(
                    icon: Icons.schedule_rounded,
                    title: 'Today\'s Classes',
                    subtitle: 'Book group sessions',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                    ),
                    onTap: _showClassSchedule,
                  ),
                  _buildFeatureCard(
                    icon: Icons.person_add_rounded,
                    title: 'Personal Trainer',
                    subtitle: 'Upcoming PT sessions',
                    gradient: CosarcColors.brandSweep,
                    onTap: _showPersonalTrainer,
                  ),
                  _buildFeatureCard(
                    icon: Icons.leaderboard_rounded,
                    title: 'Gym Leaderboard',
                    subtitle: 'Compete for the top',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF5722), Color(0xFFE64A19)],
                    ),
                    onTap: _showLeaderboard,
                  ),
                ]),
              ),
            ),

            // 4. CLASSES SECTION
            const SliverToBoxAdapter(
              child: CosarcSectionHeader(
                title: 'Classes',
                subtitle: 'Upcoming scheduled classes',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: CosarcSpacing.screenHorizontal),
              sliver: _upcomingClasses.isEmpty
                ? SliverToBoxAdapter(
                    child: _buildEmptyCard('No upcoming classes booked.', Icons.event_busy_rounded),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: CosarcSpacing.sm),
                          child: CosarcGlass(
                            highlight: true,
                            padding: const EdgeInsets.all(CosarcSpacing.md),
                            child: Row(
                              children: [
                                const Icon(Icons.notifications_active_rounded, color: CosarcColors.warning),
                                const SizedBox(width: CosarcSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Upcoming Class', style: CosarcTypography.caption(context).copyWith(color: CosarcColors.warning)),
                                      Text(_upcomingClasses[index].gymClass!.name, style: CosarcTypography.body(context).copyWith(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: _upcomingClasses.length,
                    ),
                  ),
            ),

            // 5. TRAINERS SECTION
            const SliverToBoxAdapter(
              child: CosarcSectionHeader(
                title: 'Trainers',
                subtitle: 'Trainer of the Week',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: CosarcSpacing.screenHorizontal),
              sliver: SliverToBoxAdapter(
                child: _trainers.any((t) => t.isTrainerOfWeek)
                  ? CosarcGlass(
                      padding: const EdgeInsets.all(CosarcSpacing.lg),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: CosarcColors.primary,
                            child: Icon(Icons.person, color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: CosarcSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_trainers.firstWhere((t) => t.isTrainerOfWeek).name, style: CosarcTypography.title(context)),
                                Text(_trainers.firstWhere((t) => t.isTrainerOfWeek).specialization ?? 'Elite Coach', style: CosarcTypography.caption(context)),
                              ],
                            ),
                          ),
                          const Icon(Icons.star_rounded, color: CosarcColors.warning),
                        ],
                      ),
                    )
                  : _buildEmptyCard('No trainer of the week featured.', Icons.person_off_rounded),
              ),
            ),

            // 6. CHALLENGES & ACHIEVEMENTS SECTION
            const SliverToBoxAdapter(
              child: CosarcSectionHeader(
                title: 'Challenges & Achievements',
                subtitle: 'Active events and earned badges',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: CosarcSpacing.screenHorizontal),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    if (_challenges.isEmpty && _memberBadges.isEmpty)
                      _buildEmptyCard('No active challenges or badges earned yet.', Icons.military_tech_rounded)
                    else ...[
                      if (_challenges.isNotEmpty)
                        ..._challenges.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: CosarcSpacing.sm),
                          child: CosarcGlass(
                            padding: const EdgeInsets.all(CosarcSpacing.lg),
                            child: Row(
                              children: [
                                const Icon(Icons.flag_rounded, color: CosarcColors.primary, size: 32),
                                const SizedBox(width: CosarcSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(c.title, style: CosarcTypography.title(context).copyWith(fontSize: 16)),
                                      Text(c.description, style: CosarcTypography.caption(context)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: CosarcSpacing.sm, vertical: CosarcSpacing.xxs),
                                  decoration: BoxDecoration(
                                    color: CosarcColors.warning.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(CosarcSpacing.radiusPill),
                                  ),
                                  child: Text('+${c.rewardPoints} pts', style: CosarcTypography.overline('PTS', color: CosarcColors.warning)),
                                ),
                              ],
                            ),
                          ),
                        )),
                      if (_memberBadges.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _memberBadges.length,
                            itemBuilder: (context, index) {
                              final badge = _memberBadges[index].badge!;
                              final color = Color(int.parse(badge.colorHex.replaceAll('#', '0xFF')));
                              return Padding(
                                padding: const EdgeInsets.only(right: CosarcSpacing.md),
                                child: CosarcGlass(
                                  padding: const EdgeInsets.all(CosarcSpacing.md),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.military_tech_rounded, color: color, size: 28),
                                      const SizedBox(height: CosarcSpacing.xxs),
                                      Text(badge.name, style: CosarcTypography.caption(context)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),

            // ALERTS
            const SliverToBoxAdapter(
              child: CosarcSectionHeader(
                title: 'Gym Announcements',
                subtitle: 'Updates from your facility',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: CosarcSpacing.screenHorizontal),
              sliver: _alerts.isEmpty
                ? SliverToBoxAdapter(
                    child: _buildEmptyCard('No new announcements.', Icons.campaign_rounded),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final alert = _alerts[index];
                        final hex = alert.colorHex.replaceAll('#', '0xFF');
                        final color = Color(int.parse(hex));
                        final time = alert.createdAt.difference(DateTime.now()).inDays.abs() == 0 
                            ? 'Today' : '${alert.createdAt.difference(DateTime.now()).inDays.abs()}d ago';
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: CosarcSpacing.sm),
                          child: _buildAlertCard(
                            icon: Icons.info_outline_rounded,
                            title: alert.title,
                            message: alert.message,
                            color: color,
                            time: time,
                          ),
                        );
                      },
                      childCount: _alerts.length,
                    ),
                  ),
            ),
            
            // 8. MEMBERSHIP PROGRESS (Feature 9)
            const SliverToBoxAdapter(
              child: CosarcSectionHeader(
                overline: 'Membership Progress',
                title: 'Premium access',
                subtitle: 'Active plan details',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: CosarcSpacing.screenHorizontal),
              sliver: SliverToBoxAdapter(
                child: _membership == null
                  ? _buildEmptyCard('You do not have an active membership plan.', Icons.card_membership_rounded)
                  : _buildMembershipCard(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message, IconData icon) {
    return CosarcGlass(
      padding: const EdgeInsets.all(CosarcSpacing.lg),
      child: Row(
        children: [
          Icon(icon, color: CosarcColors.textTertiary, size: 28),
          const SizedBox(width: CosarcSpacing.md),
          Expanded(child: Text(message, style: CosarcTypography.body(context).copyWith(color: CosarcColors.textSecondary))),
        ],
      ),
    );
  }

  Widget _buildCheckInCard(bool isCheckedIn) {
    final activeColor = isCheckedIn ? CosarcColors.success : CosarcColors.primary;

    return CosarcGlass(
      highlight: isCheckedIn,
      expand: true,
      padding: const EdgeInsets.all(CosarcSpacing.xl),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor,
                  boxShadow: CosarcColors.glow(activeColor, 0.5),
                ),
              ),
              const SizedBox(width: CosarcSpacing.xs),
              Text(
                isCheckedIn ? 'ACTIVE SESSION' : 'READY TO TRAIN',
                style: CosarcTypography.overline(
                  isCheckedIn ? 'ACTIVE SESSION' : 'READY TO TRAIN',
                  color: activeColor,
                ),
              ),
              const Spacer(),
              Icon(
                isCheckedIn ? Icons.fitness_center_rounded : Icons.qr_code_scanner_rounded,
                color: activeColor.withOpacity(0.7),
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: CosarcSpacing.xl),
          Text(
            isCheckedIn ? _formatDuration(_sessionDuration) : '00:00:00',
            style: CosarcTypography.metric(
              isCheckedIn ? _formatDuration(_sessionDuration) : '00:00:00',
              color: CosarcColors.textPrimary,
            ).copyWith(
              fontSize: 48,
              letterSpacing: 2,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: CosarcSpacing.xs),
          Text(
            isCheckedIn ? 'Session elapsed' : 'Tap to check in',
            style: CosarcTypography.caption(context),
          ),
          const SizedBox(height: CosarcSpacing.xl),
          CosarcButton(
            label: isCheckedIn ? 'Check Out' : 'Check In',
            icon: isCheckedIn ? Icons.logout_rounded : Icons.qr_code_scanner_rounded,
            variant: isCheckedIn ? CosarcButtonVariant.secondary : CosarcButtonVariant.primary,
            onPressed: _handleCheckInOut,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionStats() {
    if (_activeSession == null) return const SizedBox.shrink();
    return CosarcGlass(
      expand: true,
      padding: const EdgeInsets.symmetric(horizontal: CosarcSpacing.lg, vertical: CosarcSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(CosarcSpacing.xs),
            decoration: BoxDecoration(
              color: CosarcColors.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(CosarcSpacing.radiusSm),
            ),
            child: const Icon(Icons.schedule_rounded, color: CosarcColors.success, size: 18),
          ),
          const SizedBox(width: CosarcSpacing.sm),
          Expanded(
            child: Text(
              'Checked in at ${_activeSession!.checkInTime.hour.toString().padLeft(2, '0')}:${_activeSession!.checkInTime.minute.toString().padLeft(2, '0')}',
              style: CosarcTypography.caption(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final thisMonth = _attendanceHistory.where((a) => a.checkInTime.month == DateTime.now().month && a.checkInTime.year == DateTime.now().year).length;
    final total = _attendanceHistory.length;
    
    int streak = 0;
    if (_attendanceHistory.isNotEmpty) {
      DateTime lastDate = _attendanceHistory.first.checkInTime;
      if (lastDate.difference(DateTime.now()).inDays.abs() <= 1) {
        streak = 1;
        for (int i = 1; i < _attendanceHistory.length; i++) {
          final diff = lastDate.difference(_attendanceHistory[i].checkInTime).inDays.abs();
          if (diff == 1) {
            streak++;
            lastDate = _attendanceHistory[i].checkInTime;
          } else if (diff > 1) {
            break;
          }
        }
      }
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'This Month',
            value: thisMonth.toString(),
            icon: Icons.check_circle_outline_rounded,
            color: CosarcColors.success,
          ),
        ),
        const SizedBox(width: CosarcSpacing.sm),
        Expanded(
          child: _buildStatCard(
            label: 'Streak',
            value: streak.toString(),
            icon: Icons.local_fire_department_rounded,
            color: CosarcColors.warning,
          ),
        ),
        const SizedBox(width: CosarcSpacing.sm),
        Expanded(
          child: _buildStatCard(
            label: 'Total',
            value: total.toString(),
            icon: Icons.emoji_events_rounded,
            color: CosarcColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String label, required String value, required IconData icon, required Color color}) {
    return CosarcGlass(
      padding: const EdgeInsets.all(CosarcSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: CosarcSpacing.sm),
          Text(
            value,
            style: CosarcTypography.metric(value, color: CosarcColors.textPrimary).copyWith(fontSize: 28),
          ),
          const SizedBox(height: CosarcSpacing.xxs),
          Text(label, style: CosarcTypography.overline(label)),
        ],
      ),
    );
  }

  Widget _buildMembershipCard() {
    if (_membership == null) return const SizedBox.shrink();

    final daysLeft = _membership!.daysLeft;
    final totalDays = _membership!.expiryDate.difference(_membership!.startDate).inDays;
    final progress = totalDays > 0 ? (totalDays - daysLeft) / totalDays : 1.0;

    return CosarcGlass(
      highlight: true,
      expand: true,
      padding: const EdgeInsets.all(CosarcSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(CosarcSpacing.sm),
                decoration: BoxDecoration(
                  color: CosarcColors.primaryMuted,
                  borderRadius: BorderRadius.circular(CosarcSpacing.radiusSm),
                ),
                child: const Icon(Icons.card_membership_rounded, color: CosarcColors.primary, size: 24),
              ),
              const SizedBox(width: CosarcSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PREMIUM MEMBER',
                      style: CosarcTypography.overline('PREMIUM MEMBER', color: CosarcColors.primary),
                    ),
                    const SizedBox(height: CosarcSpacing.xxs),
                    Text(
                      _membership!.planName,
                      style: CosarcTypography.title(context).copyWith(fontSize: 17),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$daysLeft', style: CosarcTypography.metric('$daysLeft')),
                  Text('days left', style: CosarcTypography.caption(context)),
                ],
              ),
            ],
          ),
          const SizedBox(height: CosarcSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(CosarcSpacing.radiusSm),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: CosarcColors.glassFill(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(CosarcColors.primary),
            ),
          ),
          const SizedBox(height: CosarcSpacing.md),
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, size: 14, color: CosarcColors.textTertiary),
              const SizedBox(width: CosarcSpacing.xs),
              Expanded(
                child: Text(
                  'Renews on ${_membership!.expiryDate.day}/${_membership!.expiryDate.month}/${_membership!.expiryDate.year}',
                  style: CosarcTypography.caption(context),
                ),
              ),
              Text(
                _membership!.autoRenew ? 'Auto-renew ON' : 'Auto-renew OFF',
                style: CosarcTypography.caption(context).copyWith(
                  color: _membership!.autoRenew ? CosarcColors.success : CosarcColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: CosarcSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () async {
                // To safely implement "Leave Gym", we'd update logic.
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact Admin to leave gym.')));
              },
              icon: const Icon(Icons.exit_to_app_rounded, color: CosarcColors.error, size: 18),
              label: const Text('Leave Gym', style: TextStyle(color: CosarcColors.error)),
              style: TextButton.styleFrom(
                backgroundColor: CosarcColors.error.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(vertical: CosarcSpacing.md),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CosarcSpacing.radiusSm)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({required IconData icon, required String title, required String message, required Color color, required String time}) {
    return CosarcGlass(
      expand: true,
      padding: const EdgeInsets.all(CosarcSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(CosarcSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(CosarcSpacing.radiusSm),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: CosarcSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: CosarcTypography.title(context).copyWith(fontSize: 15)),
                const SizedBox(height: CosarcSpacing.xxs),
                Text(message, style: CosarcTypography.body(context).copyWith(fontSize: 13)),
                const SizedBox(height: CosarcSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: CosarcSpacing.sm, vertical: CosarcSpacing.xxs),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(CosarcSpacing.radiusPill),
                  ),
                  child: Text(time, style: CosarcTypography.overline(time, color: color)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({required IconData icon, required String title, required String subtitle, required Gradient gradient, required VoidCallback onTap}) {
    final accent = (gradient as LinearGradient).colors.first;
    return CosarcGlass(
      onTap: onTap,
      padding: const EdgeInsets.all(CosarcSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(CosarcSpacing.sm),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(CosarcSpacing.radiusSm),
              boxShadow: CosarcColors.glow(accent, 0.2),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: CosarcTypography.title(context).copyWith(fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: CosarcSpacing.xxs),
              Text(subtitle, style: CosarcTypography.caption(context), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ],
      ),
    );
  }

  void _showAttendanceHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: CosarcColors.backgroundElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(CosarcSpacing.radiusXl)),
          border: Border.all(color: CosarcColors.borderStrong),
        ),
        child: Column(
          children: [
            const SizedBox(height: CosarcSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: CosarcColors.textTertiary,
                borderRadius: BorderRadius.circular(CosarcSpacing.radiusPill),
              ),
            ),
            const SizedBox(height: CosarcSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: CosarcSpacing.screenHorizontal),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Session History & Heatmap', style: CosarcTypography.title(context).copyWith(fontSize: 22)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: CosarcColors.textPrimary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _attendanceHistory.isEmpty
                  ? const GymEmptyState(
                      icon: Icons.history_rounded,
                      title: 'No check-ins yet',
                      message: 'Start hitting the gym and check in to see your history.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(CosarcSpacing.screenHorizontal),
                      itemCount: _attendanceHistory.length,
                      itemBuilder: (context, index) {
                        final record = _attendanceHistory[index];
                        final date = record.checkInTime;
                        final checkIn = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                        final checkOut = record.checkOutTime != null
                            ? '${record.checkOutTime!.hour.toString().padLeft(2, '0')}:${record.checkOutTime!.minute.toString().padLeft(2, '0')}'
                            : 'Active';

                        final duration = record.checkOutTime != null 
                            ? record.checkOutTime!.difference(date) 
                            : Duration.zero;
                        
                        final durationStr = record.checkOutTime != null 
                            ? '${duration.inHours}h ${duration.inMinutes.remainder(60)}m' 
                            : 'In progress';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: CosarcSpacing.sm),
                          child: CosarcGlass(
                            padding: const EdgeInsets.all(CosarcSpacing.md),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(CosarcSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: CosarcColors.success.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(CosarcSpacing.radiusSm),
                                  ),
                                  child: const Icon(Icons.check_circle_rounded, color: CosarcColors.success, size: 18),
                                ),
                                const SizedBox(width: CosarcSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${date.day}/${date.month}/${date.year}', style: CosarcTypography.title(context).copyWith(fontSize: 15)),
                                      const SizedBox(height: 2),
                                      Text('$checkIn - $checkOut', style: CosarcTypography.caption(context)),
                                    ],
                                  ),
                                ),
                                Text(
                                  durationStr,
                                  style: CosarcTypography.caption(context).copyWith(
                                    color: CosarcColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClassSchedule() {
    if (!mounted || _membership == null || _memberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Join a gym first.')));
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ClassScheduleSheet(
        gymId: _membership!.gymId,
        memberId: _memberId!,
      ),
    );
  }

  void _showPersonalTrainer() {
    if (!mounted || _membership == null || _memberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Join a gym first.')));
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TrainerSheet(
        gymId: _membership!.gymId,
        memberId: _memberId!,
      ),
    );
  }

  void _showLeaderboard() {
    if (!mounted || _membership == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Join a gym first.')));
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LeaderboardSheet(
        gymId: _membership!.gymId,
      ),
    );
  }
}
