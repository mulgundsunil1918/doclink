-- Doclink initial schema
-- Run this entire file in Supabase SQL Editor → New Query → Run

-- ── Extensions ────────────────────────────────────────────────────────────────
create extension if not exists "uuid-ossp";

-- ── Enum types ─────────────────────────────────────────────────────────────────
create type user_role           as enum ('doctor', 'patient', 'receptionist');
create type appointment_type    as enum ('video', 'audio', 'chat', 'in_person');
create type appointment_status  as enum ('pending', 'confirmed', 'ongoing', 'completed', 'cancelled');
create type payment_status      as enum ('pending', 'success', 'failed', 'refunded');

-- ── profiles (one per auth user) ──────────────────────────────────────────────
create table profiles (
  id          uuid references auth.users on delete cascade primary key,
  role        user_role not null,
  name        text not null,
  phone       text,
  avatar_url  text,
  fcm_token   text,
  created_at  timestamptz default now()
);

-- ── doctors ───────────────────────────────────────────────────────────────────
create table doctors (
  id                uuid references profiles(id) on delete cascade primary key,
  specialty         text    not null default 'General Physician',
  registration_no   text,
  city              text,
  clinic_name       text,
  consultation_fee  numeric(10,2) default 500,
  rating            numeric(3,2)  default 0,
  total_patients    int           default 0,
  whatsapp_number   text,
  bio               text,
  available         boolean default true,
  kyc_verified      boolean default false,
  earnings_today    numeric(10,2) default 0,
  earnings_month    numeric(10,2) default 0
);

-- ── patients ──────────────────────────────────────────────────────────────────
create table patients (
  id           uuid references profiles(id) on delete cascade primary key,
  age          int,
  gender       text,
  blood_group  text,
  address      text
);

-- ── receptionists ─────────────────────────────────────────────────────────────
create table receptionists (
  id           uuid references profiles(id) on delete cascade primary key,
  clinic_name  text,
  shift        text default 'morning'
);

-- ── family_members ────────────────────────────────────────────────────────────
create table family_members (
  id          uuid primary key default uuid_generate_v4(),
  patient_id  uuid references patients(id) on delete cascade not null,
  name        text not null,
  relation    text not null,
  age         int,
  gender      text,
  blood_group text,
  conditions  text[] default '{}',
  is_primary  boolean default false,
  created_at  timestamptz default now()
);

-- ── appointments ──────────────────────────────────────────────────────────────
create table appointments (
  id                uuid primary key default uuid_generate_v4(),
  doctor_id         uuid references doctors(id) not null,
  patient_id        uuid references patients(id) not null,
  family_member_id  uuid references family_members(id),
  type              appointment_type   not null default 'in_person',
  status            appointment_status not null default 'pending',
  token_no          int,
  chief_complaint   text,
  scheduled_at      timestamptz,
  notes             text,
  receptionist_id   uuid references profiles(id),
  created_at        timestamptz default now()
);

-- ── prescriptions ─────────────────────────────────────────────────────────────
create table prescriptions (
  id              uuid primary key default uuid_generate_v4(),
  appointment_id  uuid references appointments(id),
  doctor_id       uuid references doctors(id) not null,
  patient_id      uuid references patients(id) not null,
  diagnosis       text not null,
  notes           text,
  follow_up_date  date,
  created_at      timestamptz default now()
);

-- ── medicines (child of prescription) ─────────────────────────────────────────
create table medicines (
  id               uuid primary key default uuid_generate_v4(),
  prescription_id  uuid references prescriptions(id) on delete cascade not null,
  name             text not null,
  dosage           text,
  frequency        text,
  duration         text,
  instructions     text
);

-- ── payments ──────────────────────────────────────────────────────────────────
create table payments (
  id                    uuid primary key default uuid_generate_v4(),
  appointment_id        uuid references appointments(id) not null,
  patient_id            uuid references patients(id) not null,
  amount                numeric(10,2) not null,
  method                text default 'upi',
  status                payment_status default 'pending',
  razorpay_order_id     text,
  razorpay_payment_id   text,
  created_at            timestamptz default now()
);

-- ── notifications ─────────────────────────────────────────────────────────────
create table notifications (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid references profiles(id) on delete cascade not null,
  title       text not null,
  body        text,
  type        text,
  read        boolean default false,
  created_at  timestamptz default now()
);

-- ── Auto-create profile on signup ─────────────────────────────────────────────
create or replace function handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into profiles (id, role, name, phone)
  values (
    new.id,
    (new.raw_user_meta_data->>'role')::user_role,
    coalesce(new.raw_user_meta_data->>'name', 'User'),
    new.phone
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- ── Row Level Security ────────────────────────────────────────────────────────
alter table profiles       enable row level security;
alter table doctors        enable row level security;
alter table patients       enable row level security;
alter table receptionists  enable row level security;
alter table family_members enable row level security;
alter table appointments   enable row level security;
alter table prescriptions  enable row level security;
alter table medicines      enable row level security;
alter table payments       enable row level security;
alter table notifications  enable row level security;

-- profiles
create policy "own profile read"   on profiles for select using (auth.uid() = id);
create policy "own profile update" on profiles for update using (auth.uid() = id);

-- doctors: public read (patients need to browse doctors)
create policy "doctors public read"   on doctors for select using (true);
create policy "doctor self update"    on doctors for update using (auth.uid() = id);

-- patients: own data only
create policy "patient self read"     on patients for select using (auth.uid() = id);
create policy "patient self update"   on patients for update using (auth.uid() = id);

-- receptionists
create policy "receptionist self"     on receptionists for all using (auth.uid() = id);

-- family members: patient owns them
create policy "patient owns family"   on family_members for all using (
  auth.uid() = patient_id
);

-- appointments: all parties can view
create policy "appointment parties"   on appointments for select using (
  auth.uid() = doctor_id
  or auth.uid() = patient_id
  or auth.uid() = receptionist_id
);
create policy "patient books"         on appointments for insert with check (
  auth.uid() = patient_id
);
create policy "receptionist books"    on appointments for insert with check (
  exists (select 1 from receptionists r where r.id = auth.uid())
);
create policy "doctor updates status" on appointments for update using (
  auth.uid() = doctor_id or auth.uid() = receptionist_id
);

-- prescriptions: doctor writes, patient reads
create policy "rx parties read"       on prescriptions for select using (
  auth.uid() = doctor_id or auth.uid() = patient_id
);
create policy "doctor writes rx"      on prescriptions for insert with check (
  auth.uid() = doctor_id
);

-- medicines: via prescription
create policy "medicines via rx"      on medicines for select using (
  exists (
    select 1 from prescriptions p
    where p.id = prescription_id
    and (auth.uid() = p.doctor_id or auth.uid() = p.patient_id)
  )
);
create policy "doctor writes medicine" on medicines for insert with check (
  exists (
    select 1 from prescriptions p
    where p.id = prescription_id and auth.uid() = p.doctor_id
  )
);

-- payments
create policy "payment parties read"  on payments for select using (
  auth.uid() = patient_id
  or exists (
    select 1 from appointments a
    where a.id = appointment_id and auth.uid() = a.doctor_id
  )
);
create policy "patient creates payment" on payments for insert with check (
  auth.uid() = patient_id
);

-- notifications: own only
create policy "own notifications"     on notifications for all using (
  auth.uid() = user_id
);
