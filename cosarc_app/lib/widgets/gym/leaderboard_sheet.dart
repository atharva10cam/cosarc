import 'package:flutter/material.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../models/gym_models.dart';
import '../../services/gym_service.dart';
import 'gym_empty_state.dart';

class LeaderboardSheet extends StatefulWidget {
  final String gymId;

  const LeaderboardSheet({
    super.key,
    required this.gymId,
  });

  @override
  State<LeaderboardSheet> createState() => _LeaderboardSheetState();
}

class _LeaderboardSheetState extends State<LeaderboardSheet> {
  final _gymService = GymService();
  
  bool _isLoading = true;
  List<LeaderboardEntry> _entries = [];
  
  int _selectedIndex = 0; // 0: Weekly, 1: Monthly, 2: All-Time

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final timeframe = _selectedIndex == 0 ? 'weekly' : _selectedIndex == 1 ? 'monthly' : 'all-time';
      final entries = await _gymService.getLeaderboard(widget.gymId, timeframe);
      
      if (mounted) {
        setState(() {
          _entries = entries;
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
                Text('Leaderboard', style: CosarcTypography.title(context).copyWith(fontSize: 22)),
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
                _buildTab(0, 'Weekly'),
                _buildTab(1, 'Monthly'),
                _buildTab(2, 'All-Time'),
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
        onTap: () {
          setState(() => _selectedIndex = index);
          _loadData();
        },
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
    if (_entries.isEmpty) {
      return const GymEmptyState(
        icon: Icons.emoji_events_rounded,
        title: 'No Data Yet',
        message: 'The leaderboard is empty right now. Start checking in to claim the top spot!',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(CosarcSpacing.screenHorizontal),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        final rank = index + 1;
        
        Color medalColor = CosarcColors.textSecondary;
        if (rank == 1) {
          medalColor = const Color(0xFFFFD700); // Gold
        } else if (rank == 2) {
          medalColor = const Color(0xFFC0C0C0); // Silver
        } else if (rank == 3) {
          medalColor = const Color(0xFFCD7F32); // Bronze
        }
        
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rank <= 3 ? medalColor.withOpacity(0.1) : Colors.transparent,
              border: rank > 3 ? Border.all(color: CosarcColors.borderStrong) : null,
            ),
            child: rank <= 3
                ? Icon(Icons.emoji_events_rounded, size: 18, color: medalColor)
                : Text('$rank', style: CosarcTypography.caption(context)),
          ),
          title: Text(entry.name, style: CosarcTypography.title(context)),
          trailing: Text('${_selectedIndex == 2 ? entry.longestStreak : entry.currentStreak} days', style: CosarcTypography.metric(entry.currentStreak.toString())),
        );
      },
    );
  }
}
