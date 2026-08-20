-- Phase 3: RLS completions, unique constraints, and performance indexes
-- Safe to run on existing production data — all operations are idempotent
-- Adds: workout_logs UPDATE+DELETE policies, food_logs UPDATE policy,
--        daily_contracts unique constraint, performance indexes

-- ============================================================
-- 1. MISSING RLS POLICIES
-- ============================================================

-- WORKOUT LOGS: UPDATE (was missing)
DROP POLICY IF EXISTS workout_logs_update_own ON public.workout_logs;
CREATE POLICY workout_logs_update_own ON public.workout_logs
  FOR UPDATE TO authenticated
  USING (member_id = public.current_member_id())
  WITH CHECK (member_id = public.current_member_id());

-- WORKOUT LOGS: DELETE (was missing)
DROP POLICY IF EXISTS workout_logs_delete_own ON public.workout_logs;
CREATE POLICY workout_logs_delete_own ON public.workout_logs
  FOR DELETE TO authenticated
  USING (member_id = public.current_member_id());

-- FOOD LOGS: UPDATE (was missing)
DROP POLICY IF EXISTS food_logs_update_own ON public.food_logs;
CREATE POLICY food_logs_update_own ON public.food_logs
  FOR UPDATE TO authenticated
  USING (member_id = public.current_member_id())
  WITH CHECK (member_id = public.current_member_id());

-- ============================================================
-- 2. UNIQUE CONSTRAINT ON daily_contracts(member_id, contract_date)
--    Required for safe upsert: onConflict: 'member_id,contract_date'
--    Wrapped in a DO block so it is idempotent on re-runs.
-- ============================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'daily_contracts_member_date_unique'
      AND table_name = 'daily_contracts'
      AND constraint_schema = 'public'
  ) THEN
    ALTER TABLE public.daily_contracts
      ADD CONSTRAINT daily_contracts_member_date_unique
      UNIQUE (member_id, contract_date);
  END IF;
END $$;

-- ============================================================
-- 3. PERFORMANCE INDEXES
--    All use CREATE INDEX IF NOT EXISTS — safe to run at any time.
-- ============================================================

-- Speeds up monthly workout count query: WHERE member_id = ? AND created_at >= ?
CREATE INDEX IF NOT EXISTS idx_workout_logs_member_created
  ON public.workout_logs (member_id, created_at DESC);

-- Speeds up streak lookups by member
CREATE INDEX IF NOT EXISTS idx_streaks_member_id
  ON public.streaks (member_id);

-- Speeds up daily contract date-range lookups
CREATE INDEX IF NOT EXISTS idx_daily_contracts_member_date
  ON public.daily_contracts (member_id, contract_date DESC);
