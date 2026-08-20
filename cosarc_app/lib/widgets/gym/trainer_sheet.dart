import 'package:flutter/material.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../models/gym_models.dart';
import '../../services/gym_service.dart';
import '../../services/notification_service.dart';
import 'gym_empty_state.dart';

class TrainerSheet extends StatefulWidget {
  final String gymId;
  final String memberId;

  const TrainerSheet({
    super.key,
    required this.gymId,
    required this.memberId,
  });

  @override
  State<TrainerSheet> createState() => _TrainerSheetState();
}

class _TrainerSheetState extends State<TrainerSheet> {
  final _gymService = GymService();
  final _notificationService = NotificationService();
  
  bool _isLoading = true;
  List<Trainer> _availableTrainers = [];
  List<TrainerSession> _upcomingSessions = [];
  List<TrainerSession> _sessionHistory = [];
  
  int _selectedIndex = 0; // 0: Available, 1: Upcoming, 2: History

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final available = await _gymService.getTrainers(widget.gymId);
      final upcoming = await _gymService.getMyTrainerSessions(widget.memberId, upcoming: true);
      final history = await _gymService.getMyTrainerSessions(widget.memberId, upcoming: false);
      
      if (mounted) {
        setState(() {
          _availableTrainers = available;
          _upcomingSessions = upcoming;
          _sessionHistory = history;
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _bookSession(Trainer trainer) async {
    try {
      // Mock schedule: Tomorrow at 10 AM
      final startTime = DateTime.now().add(const Duration(days: 1)).copyWith(hour: 10, minute: 0, second: 0, millisecond: 0, microsecond: 0);
      await _gymService.bookTrainerSession(trainer.id, widget.memberId, startTime, 60);
      await _notificationService.scheduleTrainerSessionReminder(trainer.name, startTime);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session booked for tomorrow 10 AM')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to book session')));
      }
    }
  }

  Future<void> _cancelSession(TrainerSession session) async {
    if (session.trainer == null) return;
    try {
      await _gymService.cancelTrainerSession(session.id);
      await _notificationService.cancelTrainerReminder(session.trainer!.name);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session Cancelled')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to cancel')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                Text('Personal Trainers', style: CosarcTypography.title(context).copyWith(fontSize: 22)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: CosarcColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: CosarcSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CosarcSpacing.screenHorizontal),
            child: Row(
              children: [
                _buildTab(0, 'Trainers'),
                _buildTab(1, 'Upcoming'),
                _buildTab(2, 'History'),
              ],
            ),
          ),
          const SizedBox(height: CosarcSpacing.sm),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: CosarcColors.primary))
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: CosarcSpacing.sm),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? CosarcColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: CosarcTypography.overline(label, color: isSelected ? CosarcColors.primary : CosarcColors.textTertiary),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedIndex == 0) {
      if (_availableTrainers.isEmpty) {
        return const GymEmptyState(
          icon: Icons.person_off_rounded,
          title: 'No Trainers Available',
          message: 'There are no personal trainers at your gym currently.',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(CosarcSpacing.screenHorizontal),
        itemCount: _availableTrainers.length,
        itemBuilder: (context, index) {
          final trainer = _availableTrainers[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(trainer.name, style: CosarcTypography.title(context)),
            subtitle: Text(trainer.specialization ?? 'General Fitness', style: CosarcTypography.caption(context)),
            trailing: TextButton(
              onPressed: () => _bookSession(trainer),
              style: TextButton.styleFrom(
                backgroundColor: CosarcColors.primary.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CosarcSpacing.radiusSm)),
              ),
              child: const Text('Book', style: TextStyle(color: CosarcColors.primary)),
            ),
          );
        },
      );
    } else if (_selectedIndex == 1) {
      if (_upcomingSessions.isEmpty) {
        return const GymEmptyState(
          icon: Icons.event_available_rounded,
          title: 'No Upcoming Sessions',
          message: 'You haven\'t booked any personal trainers yet.',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(CosarcSpacing.screenHorizontal),
        itemCount: _upcomingSessions.length,
        itemBuilder: (context, index) {
          final session = _upcomingSessions[index];
          final trainer = session.trainer;
          if (trainer == null) return const SizedBox.shrink();
          
          final time = '${session.startTime.hour.toString().padLeft(2, '0')}:${session.startTime.minute.toString().padLeft(2, '0')}';
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(trainer.name, style: CosarcTypography.title(context)),
            subtitle: Text('Tomorrow • $time', style: CosarcTypography.caption(context)),
            trailing: TextButton(
              onPressed: () => _cancelSession(session),
              style: TextButton.styleFrom(
                backgroundColor: CosarcColors.error.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CosarcSpacing.radiusSm)),
              ),
              child: const Text('Cancel', style: TextStyle(color: CosarcColors.error)),
            ),
          );
        },
      );
    } else {
      if (_sessionHistory.isEmpty) {
        return const GymEmptyState(
          icon: Icons.history_rounded,
          title: 'No Session History',
          message: 'Your past sessions will appear here.',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(CosarcSpacing.screenHorizontal),
        itemCount: _sessionHistory.length,
        itemBuilder: (context, index) {
          final session = _sessionHistory[index];
          final trainer = session.trainer;
          if (trainer == null) return const SizedBox.shrink();
          
          final date = '${session.startTime.day}/${session.startTime.month}';
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(trainer.name, style: CosarcTypography.title(context)),
            subtitle: Text(date, style: CosarcTypography.caption(context)),
            trailing: Text(session.status, style: CosarcTypography.overline(session.status)),
          );
        },
      );
    }
  }
}
