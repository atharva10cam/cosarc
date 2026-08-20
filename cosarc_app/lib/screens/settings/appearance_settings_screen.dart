import 'package:flutter/material.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_glass.dart';
import '../../widgets/cosarc/cosarc_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  String _theme = 'Dark';
  String _accent = 'Gold';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _theme = prefs.getString('theme') ?? 'Dark';
      _accent = prefs.getString('accent') ?? 'Gold';
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
                Text('Appearance', style: CosarcTypography.headline(context)),
              ],
            ),
            const SizedBox(height: CosarcSpacing.xl),
            _PickerRow(
              title: 'Theme',
              value: _theme,
              options: const ['Dark', 'System'],
              onChanged: (v) async {
                setState(() => _theme = v);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('theme', v);
                themeNotifier.value =
                    v == 'System' ? ThemeMode.system : ThemeMode.dark;
              },
            ),
            _PickerRow(
              title: 'Accent',
              value: _accent,
              options: const ['Gold', 'Rose'],
              onChanged: (v) async {
                setState(() => _accent = v);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('accent', v);
              },
            ),
            const SizedBox(height: CosarcSpacing.huge),
          ],
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String title;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CosarcSpacing.sm),
      child: CosarcGlass(
        expand: true,
        padding: const EdgeInsets.all(CosarcSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: CosarcTypography.title(context)),
            const SizedBox(height: CosarcSpacing.sm),
            Wrap(
              spacing: CosarcSpacing.sm,
              children: options.map((option) {
                final selected = option == value;
                return ChoiceChip(
                  label: Text(option),
                  selected: selected,
                  onSelected: (_) => onChanged(option),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
