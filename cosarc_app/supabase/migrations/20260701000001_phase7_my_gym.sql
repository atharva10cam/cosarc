-- Phase 7: My Gym Complete Backend
-- Adds gyms, memberships, attendance, classes, and trainer tables

-- ─────────────────────────────────────────────────────────────────────────────
-- GYMS
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.gyms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  address TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- GYM MEMBERSHIPS
-- ─────────────────────────────────────────────────────────────────────────────
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

-- ─────────────────────────────────────────────────────────────────────────────
-- GYM ATTENDANCE
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.gym_attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id UUID NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
  gym_id UUID NOT NULL REFERENCES public.gyms(id) ON DELETE CASCADE,
  check_in_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  check_out_time TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_gym_attendance_member_id ON public.gym_attendance(member_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- TRAINERS
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.trainers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_id UUID NOT NULL REFERENCES public.gyms(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  specialization TEXT,
  bio TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- TRAINER SESSIONS
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.trainer_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trainer_id UUID NOT NULL REFERENCES public.trainers(id) ON DELETE CASCADE,
  member_id UUID NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
  start_time TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'upcoming', -- upcoming, completed, cancelled
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_trainer_sessions_member_id ON public.trainer_sessions(member_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- GYM CLASSES
-- ─────────────────────────────────────────────────────────────────────────────
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

-- ─────────────────────────────────────────────────────────────────────────────
-- CLASS BOOKINGS
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.class_bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID NOT NULL REFERENCES public.gym_classes(id) ON DELETE CASCADE,
  member_id UUID NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'booked', -- booked, cancelled
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT class_bookings_member_class_unique UNIQUE (class_id, member_id)
);

CREATE INDEX IF NOT EXISTS idx_class_bookings_member_id ON public.class_bookings(member_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- GYM ALERTS
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.gym_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_id UUID NOT NULL REFERENCES public.gyms(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  color_hex TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_gym_alerts_gym_id ON public.gym_alerts(gym_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- UPDATED_AT TRIGGERS
-- ─────────────────────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_gyms_updated_at ON public.gyms;
CREATE TRIGGER trg_gyms_updated_at
  BEFORE UPDATE ON public.gyms
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_gym_memberships_updated_at ON public.gym_memberships;
CREATE TRIGGER trg_gym_memberships_updated_at
  BEFORE UPDATE ON public.gym_memberships
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_trainers_updated_at ON public.trainers;
CREATE TRIGGER trg_trainers_updated_at
  BEFORE UPDATE ON public.trainers
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


-- ─────────────────────────────────────────────────────────────────────────────
-- RLS POLICIES
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE public.gyms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gym_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gym_attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trainers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trainer_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gym_classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.class_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gym_alerts ENABLE ROW LEVEL SECURITY;

-- Gyms: everyone can read
CREATE POLICY gyms_select_all ON public.gyms FOR SELECT TO authenticated USING (true);

-- Gym Memberships: users can read their own
CREATE POLICY gym_memberships_select_own ON public.gym_memberships FOR SELECT TO authenticated USING (member_id = public.current_member_id());

-- Gym Attendance: users can read, insert, update their own
CREATE POLICY gym_attendance_select_own ON public.gym_attendance FOR SELECT TO authenticated USING (member_id = public.current_member_id());
CREATE POLICY gym_attendance_insert_own ON public.gym_attendance FOR INSERT TO authenticated WITH CHECK (member_id = public.current_member_id());
CREATE POLICY gym_attendance_update_own ON public.gym_attendance FOR UPDATE TO authenticated USING (member_id = public.current_member_id()) WITH CHECK (member_id = public.current_member_id());

-- Trainers: everyone can read
CREATE POLICY trainers_select_all ON public.trainers FOR SELECT TO authenticated USING (true);

-- Trainer Sessions: users can read, insert, update their own
CREATE POLICY trainer_sessions_select_own ON public.trainer_sessions FOR SELECT TO authenticated USING (member_id = public.current_member_id());
CREATE POLICY trainer_sessions_insert_own ON public.trainer_sessions FOR INSERT TO authenticated WITH CHECK (member_id = public.current_member_id());
CREATE POLICY trainer_sessions_update_own ON public.trainer_sessions FOR UPDATE TO authenticated USING (member_id = public.current_member_id()) WITH CHECK (member_id = public.current_member_id());

-- Gym Classes: everyone can read
CREATE POLICY gym_classes_select_all ON public.gym_classes FOR SELECT TO authenticated USING (true);

-- Class Bookings: users can read, insert, update their own
CREATE POLICY class_bookings_select_own ON public.class_bookings FOR SELECT TO authenticated USING (member_id = public.current_member_id());
CREATE POLICY class_bookings_insert_own ON public.class_bookings FOR INSERT TO authenticated WITH CHECK (member_id = public.current_member_id());
CREATE POLICY class_bookings_update_own ON public.class_bookings FOR UPDATE TO authenticated USING (member_id = public.current_member_id()) WITH CHECK (member_id = public.current_member_id());

-- Gym Alerts: everyone can read
CREATE POLICY gym_alerts_select_all ON public.gym_alerts FOR SELECT TO authenticated USING (true);
