import 'package:flutter/material.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_glass.dart';
import '../../widgets/cosarc/cosarc_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _dailyReminders = true;
  bool _streakAlerts = true;
  bool _workoutTips = false;
  bool _productUpdates = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyReminders = prefs.getBool('workoutReminders') ?? true;
      _streakAlerts = prefs.getBool('goalProgress') ?? true;
      _workoutTips = prefs.getBool('communityUpdates') ?? false;
      _productUpdates = prefs.getBool('marketingEmails') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CosarcScaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: CosarcSpacing.screenHorizontal),
          children: [
            const SizedBox(height: CosarcSpacing.sm),
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Text('Notifications',
                    style: CosarcTypography.headline(context)),
              ],
            ),
            const SizedBox(height: CosarcSpacing.xl),
            _ToggleRow(
              title: 'Daily contract reminders',
              subtitle: 'Morning nudge to complete your four pillars',
              value: _dailyReminders,
              onChanged: (v) async {
                setState(() => _dailyReminders = v);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('workoutReminders', v);
              },
            ),
            _ToggleRow(
              title: 'Streak alerts',
              subtitle: 'Celebrate milestones and streak saves',
              value: _streakAlerts,
              onChanged: (v) async {
                setState(() => _streakAlerts = v);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('goalProgress', v);
              },
            ),
            _ToggleRow(
              title: 'Workout tips',
              subtitle: 'Occasional training insights from Cosarc',
              value: _workoutTips,
              onChanged: (v) async {
                setState(() => _workoutTips = v);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('communityUpdates', v);
              },
            ),
            _ToggleRow(
              title: 'Product updates',
              subtitle: 'New features and launch announcements',
              value: _productUpdates,
              onChanged: (v) async {
                setState(() => _productUpdates = v);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('marketingEmails', v);
              },
            ),
            const SizedBox(height: CosarcSpacing.huge),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CosarcSpacing.sm),
      child: CosarcGlass(
        expand: true,
        padding: const EdgeInsets.all(CosarcSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: CosarcTypography.title(context)
                          .copyWith(fontSize: 16)),
                  Text(subtitle, style: CosarcTypography.caption(context)),
                ],
              ),
            ),
            Switch(
              value: value,
              activeColor: CosarcColors.primary,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
