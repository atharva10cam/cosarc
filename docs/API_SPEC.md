# Gym Gateway API Specification

The `gym-gateway` edge function acts as the sole access point for the Flutter app's My Gym module into the `cosarc_erp` database.

**Endpoint URL**: `https://ccmalnekezlebsqxxlds.supabase.co/functions/v1/gym-gateway`
**Method**: `POST`
**Authentication**: Must include `Authorization: Bearer <cosarc_app_jwt>` header.

## Request Structure
All requests will use a unified payload structure:
```json
{
  "action": "ACTION_NAME",
  "payload": { 
     // action specific parameters 
  }
}
```

## Actions / Endpoints

### 1. `get_active_membership`
- **Payload**: `{}` 
- **Response**: Returns a `GymMembership` JSON object or `null`. (The `memberId` is inherently derived from the verified JWT).

### 2. `get_active_join_request`
- **Payload**: `{}`
- **Response**: Returns a `GymJoinRequest` JSON object or `null`.

### 3. `request_gym_join`
- **Payload**: `{ "gymCode": "G12345" }`
- **Response**: Returns the created `GymJoinRequest` (or auto-approves and returns `GymMembership` depending on business logic).

### 4. `leave_gym`
- **Payload**: `{ "membershipId": "uuid" }`
- **Response**: `{ "success": true }`

### 5. `switch_gym`
- **Payload**: `{ "currentMembershipId": "uuid", "newGymCode": "G54321" }`
- **Response**: Returns a `GymJoinRequest`.

### 6. `get_active_session`
- **Payload**: `{}`
- **Response**: Returns a `GymAttendance` JSON object or `null`.

### 7. `check_in`
- **Payload**: `{ "gymId": "uuid" }`
- **Response**: Returns a `GymAttendance` JSON object.

### 8. `check_out`
- **Payload**: `{ "attendanceId": "uuid" }`
- **Response**: `{ "success": true }`

### 9. `get_attendance_history`
- **Payload**: `{}`
- **Response**: Returns a List of `GymAttendance` JSON objects.

### 10. `get_gym_classes`
- **Payload**: `{ "gymId": "uuid" }`
- **Response**: Returns a List of `GymClass` JSON objects (with nested trainer info).

### 11. `get_my_class_bookings`
- **Payload**: `{ "upcoming": true }`
- **Response**: Returns a List of `ClassBooking` JSON objects.

### 12. `book_class`
- **Payload**: `{ "classId": "uuid" }`
- **Response**: Returns a `ClassBooking` JSON object.

### 13. `cancel_class_booking`
- **Payload**: `{ "bookingId": "uuid" }`
- **Response**: `{ "success": true }`

### 14. `get_trainers`
- **Payload**: `{ "gymId": "uuid" }`
- **Response**: Returns a List of `Trainer` JSON objects.

### 15. `get_my_trainer_sessions`
- **Payload**: `{ "upcoming": true }`
- **Response**: Returns a List of `TrainerSession` JSON objects.

### 16. `book_trainer_session`
- **Payload**: `{ "trainerId": "uuid", "startTime": "iso-date", "durationMinutes": 60 }`
- **Response**: Returns a `TrainerSession` JSON object.

### 17. `cancel_trainer_session`
- **Payload**: `{ "sessionId": "uuid" }`
- **Response**: `{ "success": true }`

### 18. `get_gym_alerts`
- **Payload**: `{ "gymId": "uuid" }`
- **Response**: Returns a List of `GymAlert` JSON objects.

### 19. `get_leaderboard`
- **Payload**: `{ "gymId": "uuid", "timeframe": "weekly" }`
- **Response**: Returns a List of `LeaderboardEntry` JSON objects.

### 20. `get_gym_challenges`
- **Payload**: `{ "gymId": "uuid" }` (null for global)
- **Response**: Returns a List of `GymChallenge` JSON objects.

### 21. `get_member_badges`
- **Payload**: `{}`
- **Response**: Returns a List of `MemberBadge` JSON objects.
