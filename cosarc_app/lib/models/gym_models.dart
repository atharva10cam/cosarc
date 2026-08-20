class Gym {
  final String id;
  final String name;
  final String? gymCode;
  final String? address;

  Gym({required this.id, required this.name, this.gymCode, this.address});

  factory Gym.fromJson(Map<String, dynamic> json) {
    return Gym(
      id: json['id'],
      name: json['name'],
      gymCode: json['gym_code'],
      address: json['address'],
    );
  }
}

class GymMembership {
  final String id;
  final String memberId;
  final String gymId;
  final String planName;
  final DateTime startDate;
  final DateTime expiryDate;
  final bool autoRenew;

  GymMembership({
    required this.id,
    required this.memberId,
    required this.gymId,
    required this.planName,
    required this.startDate,
    required this.expiryDate,
    required this.autoRenew,
  });

  factory GymMembership.fromJson(Map<String, dynamic> json) {
    return GymMembership(
      id: json['id'],
      memberId: json['member_id'],
      gymId: json['gym_id'],
      planName: json['plan_name'],
      startDate: DateTime.parse(json['start_date']),
      expiryDate: DateTime.parse(json['expiry_date']),
      autoRenew: json['auto_renew'] ?? true,
    );
  }

  int get daysLeft {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    return difference.inDays > 0 ? difference.inDays : 0;
  }
}

class GymAttendance {
  final String id;
  final String memberId;
  final String gymId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;

  GymAttendance({
    required this.id,
    required this.memberId,
    required this.gymId,
    required this.checkInTime,
    this.checkOutTime,
  });

  factory GymAttendance.fromJson(Map<String, dynamic> json) {
    return GymAttendance(
      id: json['id'],
      memberId: json['member_id'],
      gymId: json['gym_id'] ?? 'demo_gym_1',
      checkInTime: DateTime.parse(json['check_in_time']),
      checkOutTime: json['check_out_time'] != null
          ? DateTime.parse(json['check_out_time'])
          : null,
    );
  }
  
  Duration get duration {
    final end = checkOutTime ?? DateTime.now();
    return end.difference(checkInTime);
  }
}

class Trainer {
  final String id;
  final String gymId;
  final String name;
  final String? specialization;
  final String? bio;
  final bool isTrainerOfWeek;

  Trainer({
    required this.id,
    required this.gymId,
    required this.name,
    this.specialization,
    this.bio,
    this.isTrainerOfWeek = false,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      id: json['id'],
      gymId: json['gym_id'] ?? 'demo_gym_1',
      name: json['name'],
      specialization: json['specialization'],
      bio: json['bio'],
      isTrainerOfWeek: json['is_trainer_of_week'] ?? false,
    );
  }
}

class TrainerSession {
  final String id;
  final String trainerId;
  final String memberId;
  final DateTime startTime;
  final int durationMinutes;
  final String status;
  
  // Joined relation
  final Trainer? trainer;

  TrainerSession({
    required this.id,
    required this.trainerId,
    required this.memberId,
    required this.startTime,
    required this.durationMinutes,
    required this.status,
    this.trainer,
  });

  factory TrainerSession.fromJson(Map<String, dynamic> json) {
    return TrainerSession(
      id: json['id'],
      trainerId: json['trainer_id'],
      memberId: json['member_id'],
      startTime: DateTime.parse(json['start_time']),
      durationMinutes: json['duration_minutes'],
      status: json['status'],
      trainer: json['trainers'] != null ? Trainer.fromJson(json['trainers']) : null,
    );
  }
}

class GymClass {
  final String id;
  final String gymId;
  final String name;
  final String? description;
  final String? trainerId;
  final DateTime startTime;
  final int durationMinutes;
  final int capacity;

  // Joined relation
  final Trainer? trainer;

  GymClass({
    required this.id,
    required this.gymId,
    required this.name,
    this.description,
    this.trainerId,
    required this.startTime,
    required this.durationMinutes,
    required this.capacity,
    this.trainer,
  });

  factory GymClass.fromJson(Map<String, dynamic> json) {
    return GymClass(
      id: json['id'],
      gymId: json['gym_id'],
      name: json['name'],
      description: json['description'],
      trainerId: json['trainer_id'],
      startTime: DateTime.parse(json['start_time']),
      durationMinutes: json['duration_minutes'],
      capacity: json['capacity'],
      trainer: json['trainers'] != null ? Trainer.fromJson(json['trainers']) : null,
    );
  }
}

class ClassBooking {
  final String id;
  final String classId;
  final String memberId;
  final String status;
  
  // Joined relation
  final GymClass? gymClass;

  ClassBooking({
    required this.id,
    required this.classId,
    required this.memberId,
    required this.status,
    this.gymClass,
  });

  factory ClassBooking.fromJson(Map<String, dynamic> json) {
    return ClassBooking(
      id: json['id'],
      classId: json['class_id'],
      memberId: json['member_id'],
      status: json['status'],
      gymClass: json['gym_classes'] != null ? GymClass.fromJson(json['gym_classes']) : null,
    );
  }
}

class GymAlert {
  final String id;
  final String gymId;
  final String title;
  final String message;
  final String colorHex;
  final DateTime createdAt;

  GymAlert({
    required this.id,
    required this.gymId,
    required this.title,
    required this.message,
    required this.colorHex,
    required this.createdAt,
  });

  factory GymAlert.fromJson(Map<String, dynamic> json) {
    return GymAlert(
      id: json['id'],
      gymId: json['gym_id'],
      title: json['title'],
      message: json['message'],
      colorHex: json['color_hex'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class LeaderboardEntry {
  final String memberId;
  final String name;
  final int currentStreak;
  final int longestStreak;

  LeaderboardEntry({
    required this.memberId,
    required this.name,
    required this.currentStreak,
    required this.longestStreak,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      memberId: json['member_id'],
      name: json['name'],
      currentStreak: json['current_streak'],
      longestStreak: json['longest_streak'],
    );
  }
}

class GymJoinRequest {
  final String id;
  final String memberId;
  final String gymId;
  final String requestStatus;
  final DateTime createdAt;

  GymJoinRequest({
    required this.id,
    required this.memberId,
    required this.gymId,
    required this.requestStatus,
    required this.createdAt,
  });

  factory GymJoinRequest.fromJson(Map<String, dynamic> json) {
    return GymJoinRequest(
      id: json['id'],
      memberId: json['member_id'],
      gymId: json['gym_id'],
      requestStatus: json['request_status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class GymChallenge {
  final String id;
  final String? gymId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int rewardPoints;

  GymChallenge({
    required this.id,
    this.gymId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.rewardPoints,
  });

  factory GymChallenge.fromJson(Map<String, dynamic> json) {
    return GymChallenge(
      id: json['id'],
      gymId: json['gym_id'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      rewardPoints: json['reward_points'],
    );
  }
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final String colorHex;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.colorHex,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconName: json['icon_name'],
      colorHex: json['color_hex'],
    );
  }
}

class MemberBadge {
  final String id;
  final String memberId;
  final String badgeId;
  final DateTime earnedAt;
  
  // Joined relation
  final Badge? badge;

  MemberBadge({
    required this.id,
    required this.memberId,
    required this.badgeId,
    required this.earnedAt,
    this.badge,
  });

  factory MemberBadge.fromJson(Map<String, dynamic> json) {
    return MemberBadge(
      id: json['id'],
      memberId: json['member_id'],
      badgeId: json['badge_id'],
      earnedAt: DateTime.parse(json['earned_at']),
      badge: json['badges'] != null ? Badge.fromJson(json['badges']) : null,
    );
  }
}
