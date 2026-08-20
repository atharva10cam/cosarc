import 'package:flutter/material.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../models/gym_models.dart';
import '../../services/gym_service.dart';
import '../../services/notification_service.dart';
import 'gym_empty_state.dart';

class ClassScheduleSheet extends StatefulWidget {
  final String gymId;
  final String memberId;

  const ClassScheduleSheet({
    super.key,
    required this.gymId,
    required this.memberId,
  });

  @override
  State<ClassScheduleSheet> createState() => _ClassScheduleSheetState();
}

class _ClassScheduleSheetState extends State<ClassScheduleSheet> {
  final _gymService = GymService();
  final _notificationService = NotificationService();
  
  bool _isLoading = true;
  List<GymClass> _availableClasses = [];
  List<ClassBooking> _upcomingBookings = [];
  List<ClassBooking> _bookingHistory = [];
  
  int _selectedIndex = 0; // 0: Available, 1: Upcoming, 2: History

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final available = await _gymService.getGymClasses(widget.gymId);
      final upcoming = await _gymService.getMyClassBookings(widget.memberId, upcoming: true);
      final history = await _gymService.getMyClassBookings(widget.memberId, upcoming: false);
      
      if (mounted) {
        setState(() {
          _availableClasses = available;
          _upcomingBookings = upcoming;
          _bookingHistory = history;
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

  Future<void> _bookClass(GymClass gymClass) async {
    try {
      await _gymService.bookClass(gymClass.id, widget.memberId);
      await _notificationService.scheduleClassReminder(gymClass.name, gymClass.startTime);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Class Booked!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to book class')));
      }
    }
  }

  Future<void> _cancelBooking(ClassBooking booking) async {
    if (booking.gymClass == null) return;
    try {
      await _gymService.cancelClassBooking(booking.id);
      await _notificationService.cancelClassReminder(booking.gymClass!.name);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking Cancelled')));
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
                Text('Class Schedule', style: CosarcTypography.title(context).copyWith(fontSize: 22)),
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
                _buildTab(0, 'Available'),
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
      if (_availableClasses.isEmpty) {
        return const GymEmptyState(
          icon: Icons.event_busy_rounded,
          title: 'No Classes Available',
          message: 'There are no upcoming classes scheduled at your gym right now.',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(CosarcSpacing.screenHorizontal),
        itemCount: _availableClasses.length,
        itemBuilder: (context, index) {
          final gymClass = _availableClasses[index];
          final time = '${gymClass.startTime.hour.toString().padLeft(2, '0')}:${gymClass.startTime.minute.toString().padLeft(2, '0')}';
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(gymClass.name, style: CosarcTypography.title(context)),
            subtitle: Text('Trainer: ${gymClass.trainer?.name ?? 'TBA'} • $time', style: CosarcTypography.caption(context)),
            trailing: TextButton(
              onPressed: () => _bookClass(gymClass),
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
      if (_upcomingBookings.isEmpty) {
        return const GymEmptyState(
          icon: Icons.event_available_rounded,
          title: 'No Upcoming Classes',
          message: 'You haven\'t booked any classes yet.',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(CosarcSpacing.screenHorizontal),
        itemCount: _upcomingBookings.length,
        itemBuilder: (context, index) {
          final booking = _upcomingBookings[index];
          final gymClass = booking.gymClass;
          if (gymClass == null) return const SizedBox.shrink();
          
          final time = '${gymClass.startTime.hour.toString().padLeft(2, '0')}:${gymClass.startTime.minute.toString().padLeft(2, '0')}';
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(gymClass.name, style: CosarcTypography.title(context)),
            subtitle: Text('Trainer: ${gymClass.trainer?.name ?? 'TBA'} • $time', style: CosarcTypography.caption(context)),
            trailing: TextButton(
              onPressed: () => _cancelBooking(booking),
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
      if (_bookingHistory.isEmpty) {
        return const GymEmptyState(
          icon: Icons.history_rounded,
          title: 'No Class History',
          message: 'Your past classes will appear here.',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(CosarcSpacing.screenHorizontal),
        itemCount: _bookingHistory.length,
        itemBuilder: (context, index) {
          final booking = _bookingHistory[index];
          final gymClass = booking.gymClass;
          if (gymClass == null) return const SizedBox.shrink();
          
          final date = '${gymClass.startTime.day}/${gymClass.startTime.month}';
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(gymClass.name, style: CosarcTypography.title(context)),
            subtitle: Text('Trainer: ${gymClass.trainer?.name ?? 'TBA'} • $date', style: CosarcTypography.caption(context)),
            trailing: Text(booking.status, style: CosarcTypography.overline(booking.status)),
          );
        },
      );
    }
  }
}
