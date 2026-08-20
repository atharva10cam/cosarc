import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import '../../services/auth_service.dart';
import '../../core/supabase_config.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_glass.dart';

class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});

  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  UnityWidgetController? _unityController;
  final _authService = AuthService();
  String? _memberId;
  final bool _isUnityReady = false;
  bool _isSubmitting = false;

  Set<String> selectedMuscles = {};
  final TextEditingController _notesController = TextEditingController();
  double _duration = 30;
  double _intensity = 50;

  final List<String> muscleGroups = [
    'Abs',
    'Arms',
    'Back',
    'Chest',
    'Legs',
    'Shoulders',
    'Traps'
  ];

  @override
  void initState() {
    super.initState();
    _loadMemberId();
  }

  Future<void> _loadMemberId() async {
    _memberId = await _authService.getMemberId();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onUnityCreated(UnityWidgetController controller) {
    _unityController = controller;
  }

  void _toggleMuscle(String muscle) {
    setState(() {
      if (selectedMuscles.contains(muscle)) {
        selectedMuscles.remove(muscle);
      } else {
        selectedMuscles.add(muscle);
      }
    });

    if (_unityController != null) {
      _unityController!.postMessage(
        'FlutterCommunication',
        'SelectMuscles',
        selectedMuscles.join(','),
      );
    }
  }

  String _getIntensityLabel() {
    if (_intensity < 33) return '🧘 Light';
    if (_intensity < 67) return '🔥 Moderate';
    return '💀 Brutal';
  }

  bool get _canSubmit {
    return _memberId != null &&
        selectedMuscles.isNotEmpty &&
        _notesController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: _isUnityReady
                ? UnityWidget(
                    onUnityCreated: _onUnityCreated,
                    fullscreen: false,
                  )
                : Center(
                    child: CosarcGlass(
                      radius: CosarcSpacing.radiusMd,
                      blur: 16,
                      padding: const EdgeInsets.all(CosarcSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.view_in_ar_rounded,
                              size: 48, color: Colors.white.withOpacity(0.5)),
                          const SizedBox(height: CosarcSpacing.sm),
                          Text('3D Model Unavailable',
                              style: CosarcTypography.body(context)),
                        ],
                      ),
                    ),
                  ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const Spacer(),
                _buildBottomSheet(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: CosarcSpacing.md, vertical: CosarcSpacing.sm),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const CosarcGlass(
              radius: CosarcSpacing.radiusMd,
              blur: 16,
              padding: EdgeInsets.all(10),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 16),
            ),
          ),
          const SizedBox(width: CosarcSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WORKOUT', style: CosarcTypography.overline('')),
              Text('Log session',
                  style:
                      CosarcTypography.title(context).copyWith(fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    final screenHeight = MediaQuery.of(context).size.height;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
          top: Radius.circular(CosarcSpacing.radiusXl)),
      child: CosarcGlass(
        radius: 0,
        blur: 32,
        opacity: 0.12,
        padding: EdgeInsets.zero,
        child: Container(
          constraints: BoxConstraints(maxHeight: screenHeight * 0.6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: CosarcSpacing.sm),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: CosarcColors.glassBorder(0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: CosarcSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    CosarcSpacing.screenHorizontal,
                    0,
                    CosarcSpacing.screenHorizontal,
                    CosarcSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Target muscles'),
                      const SizedBox(height: CosarcSpacing.sm),
                      _buildMuscleSelector(),
                      const SizedBox(height: CosarcSpacing.lg),
                      _buildSectionTitle('What did you do?'),
                      const SizedBox(height: CosarcSpacing.sm),
                      _buildNotesField(),
                      const SizedBox(height: CosarcSpacing.lg),
                      _buildSectionTitle('Duration'),
                      const SizedBox(height: CosarcSpacing.sm),
                      _buildDurationSlider(),
                      const SizedBox(height: CosarcSpacing.lg),
                      _buildSectionTitle('Intensity'),
                      const SizedBox(height: CosarcSpacing.sm),
                      _buildIntensitySlider(),
                      const SizedBox(height: CosarcSpacing.xl),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title.toUpperCase(), style: CosarcTypography.overline(title));
  }

  Widget _buildMuscleSelector() {
    return Wrap(
      spacing: CosarcSpacing.xs,
      runSpacing: CosarcSpacing.xs,
      children: muscleGroups.map((muscle) {
        final isSelected = selectedMuscles.contains(muscle);
        return GestureDetector(
          onTap: () => _toggleMuscle(muscle),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
                horizontal: CosarcSpacing.md, vertical: CosarcSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected
                  ? CosarcColors.primaryMuted
                  : CosarcColors.glassFill(0.05),
              borderRadius: BorderRadius.circular(CosarcSpacing.radiusPill),
              border: Border.all(
                color: isSelected
                    ? CosarcColors.primary.withOpacity(0.5)
                    : CosarcColors.glassBorder(),
              ),
            ),
            child: Text(
              muscle,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? CosarcColors.primary
                    : CosarcColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesField() {
    return CosarcGlass(
      radius: CosarcSpacing.radiusMd,
      blur: 12,
      padding: const EdgeInsets.all(CosarcSpacing.md),
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        style: CosarcTypography.body(context, color: CosarcColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'e.g., Bench press 3x10, Squats 4x8...',
          hintStyle: CosarcTypography.caption(context),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildDurationSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Duration',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Text(
                '${_duration.toInt()} min',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: CosarcColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: CosarcColors.primary,
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              thumbColor: CosarcColors.primary,
              overlayColor: CosarcColors.primary.withOpacity(0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _duration,
              min: 5,
              max: 120,
              divisions: 23,
              onChanged: (value) => setState(() => _duration = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntensitySlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Intensity',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Text(
                _getIntensityLabel(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: CosarcColors.primary,
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              thumbColor: CosarcColors.primary,
              overlayColor: CosarcColors.primary.withOpacity(0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _intensity,
              min: 0,
              max: 100,
              onChanged: (value) => setState(() => _intensity = value),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitWorkout() async {
    if (_memberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await supabase.from('workout_logs').insert({
        'member_id': _memberId,
        'workout_date': DateTime.now().toIso8601String().split('T')[0],
        'target_muscles': selectedMuscles.toList(),
        'exercises': _notesController.text,
        'duration_minutes': _duration.toInt(),
        'intensity': _intensity.toInt(),
      }).timeout(const Duration(seconds: 10));

      final today = DateTime.now().toIso8601String().split('T')[0];
      await supabase
          .from('daily_contracts')
          .update({'workout_completed': true})
          .eq('member_id', _memberId!)
          .eq('contract_date', today)
          .timeout(const Duration(seconds: 10));

      await supabase
          .rpc('calculate_streak', params: {'p_member_id': _memberId}).timeout(
        const Duration(seconds: 10),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout logged successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error logging workout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildSubmitButton() {
    final bool canSubmitNow = _canSubmit && !_isSubmitting;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canSubmitNow ? _submitWorkout : null,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: canSubmitNow
                ? LinearGradient(
                    colors: [
                      CosarcColors.primary,
                      CosarcColors.primary.withOpacity(0.8)
                    ],
                  )
                : null,
            color: canSubmitNow ? null : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            boxShadow: canSubmitNow
                ? [
                    BoxShadow(
                      color: CosarcColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Confirm Workout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: canSubmitNow
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
