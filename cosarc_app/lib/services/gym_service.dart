import '../core/supabase_config.dart';
import '../models/gym_models.dart';
import 'gym_api_service.dart';

class GymService {
  final _api = GymApiService();

  // Gym Memberships
  Future<GymMembership?> getActiveMembership(String memberId) async {
    final response = await _api.callGateway('get_active_membership');
    if (response != null) {
      return GymMembership.fromJson(response);
    }
    return null;
  }

  // Gym Join Requests
  Future<GymJoinRequest?> getActiveJoinRequest(String memberId) async {
    final response = await _api.callGateway('get_active_join_request');
    if (response != null) {
      return GymJoinRequest.fromJson(response);
    }
    return null;
  }

  Future<GymJoinRequest> requestGymJoin(String memberId, String gymCode) async {
    final response = await _api.callGateway('request_gym_join', {'gymCode': gymCode});
    return GymJoinRequest.fromJson(response);
  }

  Future<void> leaveGym(String membershipId) async {
    await _api.callGateway('leave_gym', {'membershipId': membershipId});
  }

  Future<GymJoinRequest> switchGym(String memberId, String currentMembershipId, String newGymCode) async {
    final response = await _api.callGateway('switch_gym', {
      'currentMembershipId': currentMembershipId,
      'newGymCode': newGymCode
    });
    return GymJoinRequest.fromJson(response);
  }

  // Attendance
  Future<GymAttendance?> getActiveSession(String memberId) async {
    final response = await _api.callGateway('get_active_session');
    if (response != null) {
      return GymAttendance.fromJson(response);
    }
    return null;
  }

  Future<GymAttendance> checkIn(String memberId, String gymId) async {
    final response = await _api.callGateway('check_in', {'gymId': gymId});
    return GymAttendance.fromJson(response);
  }

  Future<void> checkOut(String attendanceId) async {
    await _api.callGateway('check_out', {'attendanceId': attendanceId});
  }

  Future<List<GymAttendance>> getAttendanceHistory(String memberId) async {
    final response = await _api.callGateway('get_attendance_history');
    return (response as List).map((json) => GymAttendance.fromJson(json)).toList();
  }

  // Classes
  Future<List<GymClass>> getGymClasses(String gymId) async {
    final response = await _api.callGateway('get_gym_classes', {'gymId': gymId});
    return (response as List).map((json) => GymClass.fromJson(json)).toList();
  }

  Future<List<ClassBooking>> getMyClassBookings(String memberId, {bool upcoming = true}) async {
    final response = await _api.callGateway('get_my_class_bookings', {'upcoming': upcoming});
    return (response as List).map((json) => ClassBooking.fromJson(json)).toList();
  }

  Future<ClassBooking> bookClass(String classId, String memberId) async {
    final response = await _api.callGateway('book_class', {'classId': classId});
    return ClassBooking.fromJson(response);
  }
  
  Future<void> cancelClassBooking(String bookingId) async {
    await _api.callGateway('cancel_class_booking', {'bookingId': bookingId});
  }

  // Trainers
  Future<List<Trainer>> getTrainers(String gymId) async {
    final response = await _api.callGateway('get_trainers', {'gymId': gymId});
    return (response as List).map((json) => Trainer.fromJson(json)).toList();
  }

  Future<List<TrainerSession>> getMyTrainerSessions(String memberId, {bool upcoming = true}) async {
    final response = await _api.callGateway('get_my_trainer_sessions', {'upcoming': upcoming});
    return (response as List).map((json) => TrainerSession.fromJson(json)).toList();
  }

  Future<TrainerSession> bookTrainerSession(String trainerId, String memberId, DateTime startTime, int durationMinutes) async {
    final response = await _api.callGateway('book_trainer_session', {
      'trainerId': trainerId,
      'startTime': startTime.toIso8601String(),
      'durationMinutes': durationMinutes
    });
    return TrainerSession.fromJson(response);
  }
  
  Future<void> cancelTrainerSession(String sessionId) async {
    await _api.callGateway('cancel_trainer_session', {'sessionId': sessionId});
  }

  // Alerts
  Future<List<GymAlert>> getGymAlerts(String gymId) async {
    final response = await _api.callGateway('get_gym_alerts', {'gymId': gymId});
    return (response as List).map((json) => GymAlert.fromJson(json)).toList();
  }

  // Leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard(String gymId, String timeframe) async {
    final response = await _api.callGateway('get_leaderboard', {'gymId': gymId, 'timeframe': timeframe});
    return (response as List).map((json) => LeaderboardEntry.fromJson(json)).toList();
  }

  // Cult Features (Badges and Challenges)
  Future<List<GymChallenge>> getGymChallenges(String? gymId) async {
    final response = await _api.callGateway('get_gym_challenges', {'gymId': gymId});
    return (response as List).map((json) => GymChallenge.fromJson(json)).toList();
  }

  Future<List<MemberBadge>> getMemberBadges(String memberId) async {
    final response = await _api.callGateway('get_member_badges');
    return (response as List).map((json) => MemberBadge.fromJson(json)).toList();
  }
}
