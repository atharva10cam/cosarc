-- Row Level Security policies for Cosarc

ALTER TABLE public.members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.food_logs ENABLE ROW LEVEL SECURITY;

-- Helper: resolve member id for current auth user
CREATE OR REPLACE FUNCTION public.current_member_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT id FROM public.members WHERE auth_user_id = auth.uid() LIMIT 1;
$$;

GRANT EXECUTE ON FUNCTION public.current_member_id() TO authenticated;

-- MEMBERS
DROP POLICY IF EXISTS members_select_own ON public.members;
CREATE POLICY members_select_own ON public.members
  FOR SELECT TO authenticated
  USING (auth_user_id = auth.uid());

DROP POLICY IF EXISTS members_insert_own ON public.members;
CREATE POLICY members_insert_own ON public.members
  FOR INSERT TO authenticated
  WITH CHECK (auth_user_id = auth.uid());

DROP POLICY IF EXISTS members_update_own ON public.members;
CREATE POLICY members_update_own ON public.members
  FOR UPDATE TO authenticated
  USING (auth_user_id = auth.uid())
  WITH CHECK (auth_user_id = auth.uid());

-- STREAKS
DROP POLICY IF EXISTS streaks_select_own ON public.streaks;
CREATE POLICY streaks_select_own ON public.streaks
  FOR SELECT TO authenticated
  USING (member_id = public.current_member_id());

DROP POLICY IF EXISTS streaks_insert_own ON public.streaks;
CREATE POLICY streaks_insert_own ON public.streaks
  FOR INSERT TO authenticated
  WITH CHECK (member_id = public.current_member_id());

DROP POLICY IF EXISTS streaks_update_own ON public.streaks;
CREATE POLICY streaks_update_own ON public.streaks
  FOR UPDATE TO authenticated
  USING (member_id = public.current_member_id())
  WITH CHECK (member_id = public.current_member_id());

-- DAILY CONTRACTS
DROP POLICY IF EXISTS daily_contracts_select_own ON public.daily_contracts;
CREATE POLICY daily_contracts_select_own ON public.daily_contracts
  FOR SELECT TO authenticated
  USING (member_id = public.current_member_id());

DROP POLICY IF EXISTS daily_contracts_insert_own ON public.daily_contracts;
CREATE POLICY daily_contracts_insert_own ON public.daily_contracts
  FOR INSERT TO authenticated
  WITH CHECK (member_id = public.current_member_id());

DROP POLICY IF EXISTS daily_contracts_update_own ON public.daily_contracts;
CREATE POLICY daily_contracts_update_own ON public.daily_contracts
  FOR UPDATE TO authenticated
  USING (member_id = public.current_member_id())
  WITH CHECK (member_id = public.current_member_id());

-- WORKOUT LOGS
DROP POLICY IF EXISTS workout_logs_select_own ON public.workout_logs;
CREATE POLICY workout_logs_select_own ON public.workout_logs
  FOR SELECT TO authenticated
  USING (member_id = public.current_member_id());

DROP POLICY IF EXISTS workout_logs_insert_own ON public.workout_logs;
CREATE POLICY workout_logs_insert_own ON public.workout_logs
  FOR INSERT TO authenticated
  WITH CHECK (member_id = public.current_member_id());

-- FOOD LOGS
DROP POLICY IF EXISTS food_logs_select_own ON public.food_logs;
CREATE POLICY food_logs_select_own ON public.food_logs
  FOR SELECT TO authenticated
  USING (member_id = public.current_member_id());

DROP POLICY IF EXISTS food_logs_insert_own ON public.food_logs;
CREATE POLICY food_logs_insert_own ON public.food_logs
  FOR INSERT TO authenticated
  WITH CHECK (member_id = public.current_member_id());

DROP POLICY IF EXISTS food_logs_delete_own ON public.food_logs;
CREATE POLICY food_logs_delete_own ON public.food_logs
  FOR DELETE TO authenticated
  USING (member_id = public.current_member_id());

-- Storage bucket for profile avatars (optional)
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', false)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS avatars_select_own ON storage.objects;
CREATE POLICY avatars_select_own ON storage.objects
  FOR SELECT TO authenticated
  USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

DROP POLICY IF EXISTS avatars_insert_own ON storage.objects;
CREATE POLICY avatars_insert_own ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

DROP POLICY IF EXISTS avatars_update_own ON storage.objects;
CREATE POLICY avatars_update_own ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

DROP POLICY IF EXISTS avatars_delete_own ON storage.objects;
CREATE POLICY avatars_delete_own ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);
