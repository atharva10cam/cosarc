# Phase 8: Mobile Member App Architecture

## Overview
Phase 8 completes the mobile member application by introducing advanced features necessary for a production-level gym management app. The architecture explicitly segregates the "member app" from the "ERP system", ensuring that no administrative screens or mock data are present in this repository.

## Components Added

### 1. Database (Supabase)
- **Migration**: `20260701000002_phase8_gym_code.sql`
- **Gym Codes**: Added a `gym_code` column to `public.gyms` to allow users to securely join their specific facility.
- **RPC Logic**: Added `get_gym_leaderboard`, a PostgreSQL function running with `SECURITY DEFINER` to aggregate cross-table data (Streaks + Gym Memberships + Members) without compromising RLS or writing complex, inefficient client-side joins.

### 2. Service Layer (`GymService`)
- **Membership Operations**: Added `joinGym`, `leaveGym`, and `switchGym`. These operations map directly to the `gym_memberships` table and perform immediate state validation.
- **Booking Management**: Enhanced `bookClass` and `bookTrainerSession` with matching `cancelClassBooking` and `cancelTrainerSession` endpoints.
- **Leaderboard Integration**: Uses `.rpc('get_gym_leaderboard')` instead of mock generation.

### 3. Service Layer (`NotificationService`)
- **Cancellation Syncing**: Integrated local notification cancellation (`cancelClassReminder`, `cancelTrainerReminder`) to ensure members don't receive alerts for classes they have revoked.

### 4. UI Layer
To maintain file size and improve component reusability, complex bottom sheets were abstracted into dedicated widgets:
- `ClassScheduleSheet`: Handles Available, Upcoming, and History tabs.
- `TrainerSheet`: Handles Trainers, Upcoming sessions, and History tabs.
- `LeaderboardSheet`: Handles Weekly, Monthly, and All-Time segmentation using the RPC.
- `GymEmptyState`: A premium widget used across all empty scenarios to maintain visual parity with Cult Fit.
