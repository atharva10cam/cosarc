import 'package:flutter/material.dart';

import '../../core/supabase_config.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../services/auth_service.dart';
import '../../widgets/cosarc/cosarc_button.dart';
import '../../widgets/cosarc/cosarc_input.dart';
import '../../widgets/cosarc/cosarc_scaffold.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String _fitnessGoal = 'Not set';
  String _activityLevel = 'Not set';

  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _goals = [
    'Not set',
    'Weight Loss',
    'Muscle Gain',
    'Endurance',
    'Flexibility',
    'General Fitness'
  ];
  final List<String> _activityLevels = [
    'Not set',
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
    'Super Active'
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final memberId = await _authService.getMemberId();
      if (memberId == null) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      final member = await supabase
          .from('members')
          .select()
          .eq('id', memberId)
          .maybeSingle();

      if (member != null && mounted) {
        _nameController.text = member['name']?.toString() ?? '';
        _ageController.text = member['age']?.toString() ?? '';
        _heightController.text = member['height']?.toString() ?? '';
        _weightController.text = member['weight']?.toString() ?? '';

        final loadedGoal = member['fitness_goal']?.toString() ?? 'Not set';
        if (_goals.contains(loadedGoal)) {
          _fitnessGoal = loadedGoal;
        }

        final loadedActivity =
            member['activity_level']?.toString() ?? 'Not set';
        if (_activityLevels.contains(loadedActivity)) {
          _activityLevel = loadedActivity;
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final memberId = await _authService.getMemberId();
      if (memberId == null) return;

      final age = int.tryParse(_ageController.text) ?? 0;
      final height = double.tryParse(_heightController.text) ?? 0.0;
      final weight = double.tryParse(_weightController.text) ?? 0.0;

      await supabase.from('members').update({
        'name': _nameController.text.trim(),
        'age': age,
        'height': height,
        'weight': weight,
        'fitness_goal': _fitnessGoal,
        'activity_level': _activityLevel,
      }).eq('id', memberId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully'),
            backgroundColor: CosarcColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: CosarcColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CosarcScaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: CosarcColors.primary))
            : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: CosarcSpacing.screenHorizontal,
                vertical: CosarcSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      Text('Edit Profile',
                          style: CosarcTypography.headline(context)),
                    ],
                  ),
                  const SizedBox(height: CosarcSpacing.xl),
                  CosarcInput(
                    label: 'Full Name',
                    controller: _nameController,
                  ),
                  const SizedBox(height: CosarcSpacing.lg),
                  CosarcInput(
                    label: 'Age',
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: CosarcSpacing.lg),
                  CosarcInput(
                    label: 'Height (cm)',
                    controller: _heightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: CosarcSpacing.lg),
                  CosarcInput(
                    label: 'Weight (kg)',
                    controller: _weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: CosarcSpacing.lg),
                  Text(
                    'FITNESS GOAL',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w700,
                          color: CosarcColors.textTertiary,
                        ),
                  ),
                  const SizedBox(height: CosarcSpacing.xs),
                  DropdownButtonFormField<String>(
                    value: _fitnessGoal,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: CosarcColors.glassFill(0.04),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(CosarcSpacing.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor: CosarcColors.surface,
                    items: _goals.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,
                            style: Theme.of(context).textTheme.bodyLarge),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() => _fitnessGoal = newValue);
                      }
                    },
                  ),
                  const SizedBox(height: CosarcSpacing.lg),
                  Text(
                    'ACTIVITY LEVEL',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w700,
                          color: CosarcColors.textTertiary,
                        ),
                  ),
                  const SizedBox(height: CosarcSpacing.xs),
                  DropdownButtonFormField<String>(
                    value: _activityLevel,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: CosarcColors.glassFill(0.04),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(CosarcSpacing.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor: CosarcColors.surface,
                    items: _activityLevels.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,
                            style: Theme.of(context).textTheme.bodyLarge),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() => _activityLevel = newValue);
                      }
                    },
                  ),
                  const SizedBox(height: CosarcSpacing.xxl),
                  CosarcButton(
                    label: 'Save Profile',
                    onPressed: _saveProfile,
                    isLoading: _isSaving,
                  ),
                  const SizedBox(height: CosarcSpacing.xl),
                ],
              ),
            ),
      ),
    );
  }
}
