# COSARC PHASE 7 - DATABASE REPORT

## 1. Migration Overview
File: `supabase/migrations/20260701000001_phase7_my_gym.sql`
Purpose: Establishes the full architectural backend for the My Gym section of the application.

## 2. Table Definitions

### `gyms`
- Core table representing physical gym locations.
- **Columns:** `id`, `name`, `address`, `created_at`, `updated_at`.

### `gym_memberships`
- Represents a user's subscription to a specific gym.
- **Columns:** `id`, `member_id`, `gym_id`, `plan_name`, `start_date`, `expiry_date`, `auto_renew`.
- **Constraint:** Unique `(member_id, gym_id)` to prevent duplicate active memberships.

### `gym_attendance`
- Tracks check-ins and check-outs for tracking active sessions and duration.
- **Columns:** `id`, `member_id`, `gym_id`, `check_in_time`, `check_out_time`.

### `trainers` & `trainer_sessions`
- Represents gym staff and their booked sessions with members.
- **Trainer Columns:** `id`, `gym_id`, `name`, `specialization`, `bio`.
- **Session Columns:** `id`, `trainer_id`, `member_id`, `start_time`, `duration_minutes`, `status`.

### `gym_classes` & `class_bookings`
- Represents group fitness classes and member bookings.
- **Class Columns:** `id`, `gym_id`, `name`, `trainer_id`, `start_time`, `duration_minutes`, `capacity`.
- **Booking Columns:** `id`, `class_id`, `member_id`, `status`.
- **Constraint:** Unique `(class_id, member_id)` to prevent double booking.

### `gym_alerts`
- Represents announcements from the gym sent to members.
- **Columns:** `id`, `gym_id`, `title`, `message`, `color_hex`.

## 3. Security (Row Level Security - RLS)
- All tables have RLS enabled.
- Read operations are restricted to `authenticated` users, but `gyms`, `trainers`, `gym_classes`, and `gym_alerts` are publicly readable to all authenticated users since they are global data.
- User-specific tables (`gym_memberships`, `gym_attendance`, `class_bookings`, `trainer_sessions`) enforce `member_id = public.current_member_id()` for SELECT, INSERT, and UPDATE. This ensures zero data leakage between members.

## 4. Performance Optimization
Indexes were generated on foreign key relations and heavily queried columns:
- `idx_gym_memberships_member_id`
- `idx_gym_attendance_member_id`
- `idx_trainer_sessions_member_id`
- `idx_gym_classes_gym_id`
- `idx_gym_classes_start_time`
- `idx_class_bookings_member_id`
- `idx_gym_alerts_gym_id`
