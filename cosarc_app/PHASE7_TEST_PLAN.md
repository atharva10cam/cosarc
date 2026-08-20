# COSARC PHASE 7 - TEST PLAN

## 1. Membership Verification
- **Test Case:** Verify Membership Card
- **Action:** Load My Gym screen.
- **Expected:** If user has no active gym membership, the empty state ("No Active Membership") should display. If user has membership, the card should display the correct plan name and calculate the exact remaining days dynamically from Supabase.

## 2. Check In/Out (Attendance System)
- **Test Case:** Check In
- **Action:** Tap "Check In" button.
- **Expected:** Button changes to "Check Out". Session elapsed timer begins ticking. An attendance record is inserted into Supabase `gym_attendance`.
- **Test Case:** Check Out
- **Action:** Tap "Check Out" button.
- **Expected:** Timer stops. UI returns to "READY TO TRAIN". The corresponding row in `gym_attendance` is updated with the checkout time.
- **Test Case:** Attendance History
- **Action:** Tap "Attendance History" feature card.
- **Expected:** Bottom sheet opens and fetches real `gym_attendance` records for the logged-in user.

## 3. Class Booking
- **Test Case:** Browse Classes
- **Action:** Tap "Class Schedule" feature card.
- **Expected:** Bottom sheet fetches real classes from `gym_classes` for the user's gym.
- **Test Case:** Book Class
- **Action:** Tap "Book" on a class.
- **Expected:** Upsert record into `class_bookings`. Local notification is scheduled 30 mins prior to the start time. Success snackbar displayed.

## 4. Trainer Sessions
- **Test Case:** Browse Trainers
- **Action:** Tap "Personal Trainer" feature card.
- **Expected:** Bottom sheet fetches trainers from `trainers` for the user's gym.
- **Test Case:** Book Session
- **Action:** Tap "Book" on a trainer.
- **Expected:** Inserts into `trainer_sessions`. Local notification scheduled 1 hour prior. Success snackbar displayed.

## 5. Leaderboard
- **Test Case:** View Leaderboard
- **Action:** Tap "Gym Leaderboard" feature card.
- **Expected:** Fetches real streaks from the `streaks` table and displays the top 10 members.

## 6. Edge Cases
- **Test Case:** App Offline / Network Failure
- **Expected:** Screen should display error state with a "Retry" button. No crashes should occur.
- **Test Case:** Missing Gym Data
- **Expected:** Feature bottom sheets should display "No data available." No crashes should occur.
