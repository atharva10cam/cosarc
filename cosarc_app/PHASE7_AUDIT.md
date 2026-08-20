# COSARC - PHASE 7 AUDIT

## 1. Overview
The goal of Phase 7 is to fully implement the My Gym section with a real Supabase backend, eliminating all hardcoded data, mock features, and "coming soon" dialogs. The UI must remain visually identical while becoming fully functional.

## 2. Current State (Files Audited)
* **`my_gym_screen.dart`**: Currently contains mock data for membership status (days left, auto-renew), mock check-in/check-out timers, mock alerts, a hardcoded attendance history bottom sheet, and "Coming Soon" dialogs for Class Schedule, Personal Trainer, and Gym Leaderboard.
* **`profile_screen.dart`**: Already uses real data from `members`, `streaks`, and `workout_logs` tables for the user's profile and basic stats.
* **Database (`supabase/migrations`)**: The current schema includes `members`, `streaks`, `daily_contracts`, `workout_logs`, and `food_logs`. It lacks tables for gyms, memberships, attendance, classes, trainers, and leaderboard metrics.

## 3. Missing Infrastructure
We need to create the following database tables (with RLS, foreign keys, and indexes):
- `gyms`
- `gym_memberships`
- `gym_attendance`
- `gym_classes`
- `class_bookings`
- `trainers`
- `trainer_sessions`

## 4. UI/UX Mapping
To preserve the exact visual design while making it real:
- **Membership Card**: Fetch active plan and calculate days left from `gym_memberships`.
- **Check-in Card**: Use `gym_attendance` to track active sessions. Start a session writes a record with check-in time; checking out updates the record with check-out time.
- **Gym Alerts**: We need a way to serve real alerts (either via a `gym_alerts` table or generated based on upcoming classes/membership expiry).
- **Attendance History**: Replace the mock loop with a query to `gym_attendance`.
- **Class Schedule / Personal Trainer / Leaderboard**: The "Coming Soon" dialogs must be replaced. Since UI redesign is forbidden, we will implement these features using Bottom Sheets (similar to the existing `_showAttendanceHistory()` implementation) to maintain the current visual language and screen architecture.
- **Notifications**: Implement local notifications (using `flutter_local_notifications` if available, or basic platform channels) for reminders.

## 5. Next Steps
1. Create and apply the Phase 7 database migration.
2. Generate Dart models and a `GymService`.
3. Integrate real data into `my_gym_screen.dart`.
4. Implement Bottom Sheets for the new features.
5. Add error/loading states and local notifications.
