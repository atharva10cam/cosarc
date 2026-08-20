class OnboardingProfile {
  const OnboardingProfile._();

  static const requiredFields = [
    'gender',
    'age',
    'height',
    'weight',
    'workout_preference',
    'activity_level',
    'training_frequency',
    'fitness_goal',
  ];

  static const selectColumns =
      'gender,age,height,weight,workout_preference,activity_level,training_frequency,fitness_goal';

  static bool isComplete(Map<String, dynamic>? member) {
    if (member == null) return false;

    final gender = _string(member['gender']);
    final age = _int(member['age']);
    final height = _double(member['height']);
    final weight = _double(member['weight']);
    final preference = _string(member['workout_preference']);
    final activity = _string(member['activity_level']);
    final frequency = _int(member['training_frequency']);
    final goal = _string(member['fitness_goal']);

    return gender.isNotEmpty &&
        age >= 13 &&
        age <= 120 &&
        height > 0 &&
        weight > 0 &&
        preference.isNotEmpty &&
        activity.isNotEmpty &&
        frequency >= 1 &&
        frequency <= 7 &&
        goal.isNotEmpty;
  }

  static Map<String, dynamic> sanitize(Map<String, dynamic> data) {
    return {
      'gender': _string(data['gender']),
      'age': _int(data['age']).clamp(13, 120),
      'height': _double(data['height']),
      'weight': _double(data['weight']),
      'workout_preference': _string(data['workout_preference']),
      'activity_level': _string(data['activity_level']),
      'training_frequency': _int(data['training_frequency']).clamp(1, 7),
      'fitness_goal': _string(data['fitness_goal']),
    };
  }

  static String _string(Object? value) => value?.toString().trim() ?? '';

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _double(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
