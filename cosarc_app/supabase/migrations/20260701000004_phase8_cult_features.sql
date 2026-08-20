-- Phase 8: Cult-style Premium Features and Onboarding

-- 1. GYM JOIN REQUESTS
CREATE TABLE IF NOT EXISTS public.gym_join_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id UUID NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
  gym_id UUID NOT NULL REFERENCES public.gyms(id) ON DELETE CASCADE,
  request_status TEXT NOT NULL DEFAULT 'pending', -- pending, approved, rejected
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT gym_join_requests_unique UNIQUE (member_id, gym_id)
);
CREATE INDEX IF NOT EXISTS idx_gym_join_requests_member_id ON public.gym_join_requests(member_id);

-- Trigger for updated_at
DROP TRIGGER IF EXISTS trg_gym_join_requests_updated_at ON public.gym_join_requests;
CREATE TRIGGER trg_gym_join_requests_updated_at
  BEFORE UPDATE ON public.gym_join_requests
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 2. BADGES
CREATE TABLE IF NOT EXISTS public.badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  icon_name TEXT NOT NULL,
  color_hex TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Insert standard badges
INSERT INTO public.badges (name, description, icon_name, color_hex) VALUES 
('Early Bird', 'Checked in before 7 AM', 'wb_twilight_rounded', '#FFB300'),
('Night Owl', 'Checked in after 9 PM', 'nights_stay_rounded', '#5E35B1'),
('Streak Master', 'Maintained a 7-day streak', 'local_fire_department_rounded', '#E53935'),
('Iron Lifter', 'Completed 10 Personal Training sessions', 'fitness_center_rounded', '#424242'),
('Social Butterfly', 'Attended 5 group classes', 'groups_rounded', '#00ACC1')
ON CONFLICT DO NOTHING;

-- 3. MEMBER BADGES
CREATE TABLE IF NOT EXISTS public.member_badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id UUID NOT NULL REFERENCES public.members(id) ON DELETE CASCADE,
  badge_id UUID NOT NULL REFERENCES public.badges(id) ON DELETE CASCADE,
  earned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT member_badges_unique UNIQUE (member_id, badge_id)
);
CREATE INDEX IF NOT EXISTS idx_member_badges_member_id ON public.member_badges(member_id);

-- 4. GYM CHALLENGES
CREATE TABLE IF NOT EXISTS public.gym_challenges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_id UUID REFERENCES public.gyms(id) ON DELETE CASCADE, -- null means global challenge
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  reward_points INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_gym_challenges_gym_id ON public.gym_challenges(gym_id);

-- Insert dummy challenge
INSERT INTO public.gym_challenges (title, description, start_date, end_date, reward_points)
VALUES ('30-Day Shred', 'Check in 20 times this month to win a free PT session!', current_date, current_date + interval '30 days', 500);

-- 5. TRAINER OF THE WEEK
ALTER TABLE public.trainers ADD COLUMN IF NOT EXISTS is_trainer_of_week BOOLEAN DEFAULT false;

-- RLS POLICIES
ALTER TABLE public.gym_join_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.member_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gym_challenges ENABLE ROW LEVEL SECURITY;

-- Join Requests: Users can read and insert their own requests
CREATE POLICY gym_join_requests_select_own ON public.gym_join_requests FOR SELECT TO authenticated USING (member_id = public.current_member_id());
CREATE POLICY gym_join_requests_insert_own ON public.gym_join_requests FOR INSERT TO authenticated WITH CHECK (member_id = public.current_member_id());

-- Badges: Everyone can read
CREATE POLICY badges_select_all ON public.badges FOR SELECT TO authenticated USING (true);

-- Member Badges: Users can read their own
CREATE POLICY member_badges_select_own ON public.member_badges FOR SELECT TO authenticated USING (member_id = public.current_member_id());

-- Gym Challenges: Everyone can read
CREATE POLICY gym_challenges_select_all ON public.gym_challenges FOR SELECT TO authenticated USING (true);

