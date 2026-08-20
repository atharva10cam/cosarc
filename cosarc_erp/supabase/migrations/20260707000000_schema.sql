create table if not exists members (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text,
  phone text,
  gender text,
  age int,
  goal text,
  status text default 'Active',
  membership_start date,
  membership_end date,
  plan text,
  payment_status text default 'Pending',
  total_revenue numeric default 0,
  trainer text,
  salesperson text,
  engagement int default 60,
  notes text,
  diet_plan text,
  workout_plan text,
  frozen_until date,
  created_at timestamptz default now()
);

create table if not exists attendance (
  id uuid primary key default gen_random_uuid(),
  member_id uuid references members(id) on delete cascade,
  date date not null,
  check_in text,
  check_out text,
  duration int default 0,
  created_at timestamptz default now()
);

create table if not exists payments (
  id uuid primary key default gen_random_uuid(),
  member_id uuid references members(id) on delete cascade,
  date date not null,
  amount numeric not null default 0,
  gst numeric default 18,
  discount numeric default 0,
  status text default 'Pending',
  method text,
  invoice_no text,
  created_at timestamptz default now()
);

create table if not exists enquiries (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text,
  interest text,
  temperature text default 'Warm',
  status text default 'New',
  owner text,
  salesperson text,
  probability numeric default 35,
  source text,
  next_follow_up date,
  notes text,
  follow_ups jsonb default '[]'::jsonb,
  created_at timestamptz default now()
);

create table if not exists trainers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  specialty text,
  commission_rate numeric default 0,
  sessions int default 0,
  rating numeric default 5,
  created_at timestamptz default now()
);

create table if not exists sales_team (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  role text,
  target numeric default 0,
  revenue numeric default 0,
  conversions int default 0,
  leads int default 0,
  incentive_rate numeric default 0,
  created_at timestamptz default now()
);

create table if not exists inventory (
  id uuid primary key default gen_random_uuid(),
  item text not null,
  stock int default 0,
  low_at int default 5,
  price numeric default 0,
  created_at timestamptz default now()
);

alter table members enable row level security;
alter table attendance enable row level security;
alter table payments enable row level security;
alter table enquiries enable row level security;
alter table trainers enable row level security;
alter table sales_team enable row level security;
alter table inventory enable row level security;

create policy "authenticated members access" on members for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "authenticated attendance access" on attendance for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "authenticated payments access" on payments for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "authenticated enquiries access" on enquiries for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "authenticated trainers access" on trainers for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "authenticated sales team access" on sales_team for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "authenticated inventory access" on inventory for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- Cross-System Identity Map
create table if not exists external_identity_map (
  erp_member_id uuid references members(id) on delete cascade,
  cosarc_app_user_id uuid not null unique,
  normalized_email text,
  linked_at timestamptz default now(),
  primary key (erp_member_id, cosarc_app_user_id)
);

-- Gyms / Branches
create table if not exists gyms (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  gym_code text unique,
  address text,
  created_at timestamptz default now()
);

-- Classes
create table if not exists classes (
  id uuid primary key default gen_random_uuid(),
  gym_id uuid references gyms(id) on delete cascade,
  name text not null,
  description text,
  trainer_id uuid references trainers(id) on delete set null,
  start_time timestamptz not null,
  duration_minutes int not null,
  capacity int not null,
  created_at timestamptz default now()
);

create table if not exists class_bookings (
  id uuid primary key default gen_random_uuid(),
  class_id uuid references classes(id) on delete cascade,
  member_id uuid references members(id) on delete cascade,
  status text default 'booked',
  created_at timestamptz default now(),
  unique(class_id, member_id)
);

-- Trainer Sessions
create table if not exists trainer_sessions (
  id uuid primary key default gen_random_uuid(),
  trainer_id uuid references trainers(id) on delete cascade,
  member_id uuid references members(id) on delete cascade,
  start_time timestamptz not null,
  duration_minutes int not null,
  status text default 'upcoming',
  created_at timestamptz default now()
);

-- Alerts
create table if not exists alerts (
  id uuid primary key default gen_random_uuid(),
  gym_id uuid references gyms(id) on delete cascade,
  title text not null,
  message text not null,
  color_hex text not null,
  created_at timestamptz default now()
);

-- Challenges
create table if not exists challenges (
  id uuid primary key default gen_random_uuid(),
  gym_id uuid references gyms(id) on delete cascade,
  title text not null,
  description text,
  start_date date,
  end_date date,
  reward_points int default 0
);

-- Badges
create table if not exists badges (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  icon_name text,
  color_hex text
);

create table if not exists member_badges (
  id uuid primary key default gen_random_uuid(),
  member_id uuid references members(id) on delete cascade,
  badge_id uuid references badges(id) on delete cascade,
  earned_at timestamptz default now()
);

-- Seed Initial Data
insert into gyms (id, name, gym_code, address) 
values ('00000000-0000-0000-0000-000000000001', 'Erande''s Arena', 'ERANDE123', 'Pune, MH')
on conflict do nothing;

