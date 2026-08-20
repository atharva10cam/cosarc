-- COMPLETE GYM SETUP (Combines Phase 7 & Phase 8)
-- Run this in your Supabase SQL Editor to create the backend tables

-- 1. GYMS
CREATE TABLE IF NOT EXISTS public.gyms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  address TEXT,
  gym_code TEXT UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_gyms_gym_code ON public.gyms(gym_code);

-- Insert Demo Gyms
INSERT INTO public.gyms (name, gym_code) VALUES ('MIT Fitness', 'MITFIT01') ON CONFLICT (gym_code) DO NOTHING;
INSERT INTO public.gyms (name, gym_code) VALUES ('COSARC HQ', 'COSARC001') ON CONFLICT (gym_code) DO NOTHING;

-- 2. GYM MEMBERSHIPS
CREATE TABLE IF NOT EXISTS public.gym_memberships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id UUID NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
  gym_id UUID NOT NULL REFERENCES public.gyms(id) ON DELETE CASCADE,
  plan_name TEXT NOT NULL,
  start_date DATE NOT NULL,
  expiry_date DATE NOT NULL,
  auto_renew BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT gym_memberships_member_gym_unique UNIQUE (member_id, gym_id)
);
CREATE INDEX IF NOT EXISTS idx_gym_memberships_member_id ON public.gym_memberships(member_id);

-- 3. GYM ATTENDANCE
CREATE TABLE IF NOT EXISTS public.gym_attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id UUID NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
  gym_id UUID NOT NULL REFERENCES public.gyms(id) ON DELETE CASCADE,
  check_in_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  check_out_time TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_gym_attendance_member_id ON public.gym_attendance(member_id);

-- 4. TRAINERS
CREATE TABLE IF NOT EXISTS public.trainers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_id UUID NOT NULL REFERENCES public.gyms(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  specialization TEXT,
  bio TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 5. TRAINER SESSIONS
CREATE TABLE IF NOT EXISTS public.trainer_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trainer_id UUID NOT NULL REFERENCES public.trainers(id) ON DELETE CASCADE,
  member_id UUID NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
  start_time TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'upcoming',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_trainer_sessions_member_id ON public.trainer_sessions(member_id);

-- 6. GYM CLASSES
CREATE TABLE IF NOT EXISTS public.gym_classes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_id UUID NOT NULL REFERENCES public.gyms(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  trainer_id UUID REFERENCES public.trainers(id) ON DELETE SET NULL,
  start_time TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER NOT NULL,
  capacity INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_gym_classes_gym_id ON public.gym_classes(gym_id);
CREATE INDEX IF NOT EXISTS idx_gym_classes_start_time ON public.gym_classes(start_time);

-- 7. CLASS BOOKINGS
CREATE TABLE IF NOT EXISTS public.class_bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID NOT NULL REFERENCES public.gym_classes(id) ON DELETE CASCADE,
  member_id UUID NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'booked',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT class_bookings_member_class_unique UNIQUE (class_id, member_id)
);
CREATE INDEX IF NOT EXISTS idx_class_bookings_member_id ON public.class_bookings(member_id);

-- 8. GYM ALERTS
CREATE TABLE IF NOT EXISTS public.gym_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_id UUID NOT NULL REFERENCES public.gyms(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  color_hex TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_gym_alerts_gym_id ON public.gym_alerts(gym_id);

-- 9. RLS POLICIES
ALTER TABLE public.gyms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gym_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gym_attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trainers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trainer_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gym_classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.class_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gym_alerts ENABLE ROW LEVEL SECURITY;

-- Gyms: read all
CREATE POLICY gyms_select_all ON public.gyms FOR SELECT TO authenticated USING (true);

-- Gym Memberships: read, insert, delete own
CREATE POLICY gym_memberships_select_own ON public.gym_memberships FOR SELECT TO authenticated USING (member_id = public.current_member_id());
CREATE POLICY gym_memberships_insert_own ON public.gym_memberships FOR INSERT TO authenticated WITH CHECK (member_id = public.current_member_id());
CREATE POLICY gym_memberships_delete_own ON public.gym_memberships FOR DELETE TO authenticated USING (member_id = public.current_member_id());

-- Gym Attendance: read, insert, update own
CREATE POLICY gym_attendance_select_own ON public.gym_attendance FOR SELECT TO authenticated USING (member_id = public.current_member_id());
CREATE POLICY gym_attendance_insert_own ON public.gym_attendance FOR INSERT TO authenticated WITH CHECK (member_id = public.current_member_id());
CREATE POLICY gym_attendance_update_own ON public.gym_attendance FOR UPDATE TO authenticated USING (member_id = public.current_member_id()) WITH CHECK (member_id = public.current_member_id());

-- Trainers: read all
CREATE POLICY trainers_select_all ON public.trainers FOR SELECT TO authenticated USING (true);

-- Trainer Sessions: read, insert, update own
CREATE POLICY trainer_sessions_select_own ON public.trainer_sessions FOR SELECT TO authenticated USING (member_id = public.current_member_id());
CREATE POLICY trainer_sessions_insert_own ON public.trainer_sessions FOR INSERT TO authenticated WITH CHECK (member_id = public.current_member_id());
CREATE POLICY trainer_sessions_update_own ON public.trainer_sessions FOR UPDATE TO authenticated USING (member_id = public.current_member_id()) WITH CHECK (member_id = public.current_member_id());

-- Gym Classes: read all
CREATE POLICY gym_classes_select_all ON public.gym_classes FOR SELECT TO authenticated USING (true);

-- Class Bookings: read, insert, update own
CREATE POLICY class_bookings_select_own ON public.class_bookings FOR SELECT TO authenticated USING (member_id = public.current_member_id());
CREATE POLICY class_bookings_insert_own ON public.class_bookings FOR INSERT TO authenticated WITH CHECK (member_id = public.current_member_id());
CREATE POLICY class_bookings_update_own ON public.class_bookings FOR UPDATE TO authenticated USING (member_id = public.current_member_id()) WITH CHECK (member_id = public.current_member_id());

-- Gym Alerts: read all
CREATE POLICY gym_alerts_select_all ON public.gym_alerts FOR SELECT TO authenticated USING (true);

-- 10. LEADERBOARD RPC
CREATE OR REPLACE FUNCTION public.get_gym_leaderboard(p_gym_id UUID, p_timeframe TEXT)
RETURNS TABLE (
  member_id UUID,
  name TEXT,
  current_streak INTEGER,
  longest_streak INTEGER
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.member_id,
    m.name,
    s.current_streak,
    s.longest_streak
  FROM public.streaks s
  JOIN public.members m ON s.member_id = m.id
  JOIN public.gym_memberships gm ON gm.member_id = m.id
  WHERE gm.gym_id = p_gym_id
  ORDER BY 
    CASE WHEN p_timeframe = 'weekly' THEN s.current_streak
         WHEN p_timeframe = 'monthly' THEN s.current_streak
         ELSE s.longest_streak END DESC,
    s.current_streak DESC
  LIMIT 10;
END;
$$;
