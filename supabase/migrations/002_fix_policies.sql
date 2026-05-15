-- Migration 002: Fix RLS policies, trigger, and add messages table
-- Run in Supabase SQL Editor → New Query → Run

-- ── Fix trigger: default role to 'patient' for OTP signups ────────────────────
create or replace function handle_new_user()
returns trigger language plpgsql security definer as $$
declare
  v_role user_role;
begin
  v_role := coalesce(
    nullif(new.raw_user_meta_data->>'role', ''),
    'patient'
  )::user_role;

  insert into profiles (id, role, name, phone)
  values (
    new.id,
    v_role,
    coalesce(nullif(new.raw_user_meta_data->>'name',''), new.phone, 'User'),
    new.phone
  )
  on conflict (id) do nothing;

  if v_role = 'patient' then
    insert into patients (id) values (new.id) on conflict (id) do nothing;
  elsif v_role = 'doctor' then
    insert into doctors (id) values (new.id) on conflict (id) do nothing;
  elsif v_role = 'receptionist' then
    insert into receptionists (id) values (new.id) on conflict (id) do nothing;
  end if;

  return new;
end;
$$;

-- ── Backfill: create patients rows for any existing patient profiles ───────────
insert into patients (id)
select id from profiles where role = 'patient'
and id not in (select id from patients)
on conflict (id) do nothing;

-- ── Fix profiles RLS: allow any authenticated user to read profiles ────────────
drop policy if exists "own profile read" on profiles;
create policy "profiles readable by authenticated" on profiles
  for select using (auth.role() = 'authenticated');
create policy "own profile update" on profiles
  for update using (auth.uid() = id)
  with check (auth.uid() = id);

-- ── Fix patients RLS: doctors can read their patients ─────────────────────────
drop policy if exists "patient self read" on patients;
create policy "patients readable in context" on patients
  for select using (
    auth.uid() = id
    or exists (
      select 1 from appointments
      where appointments.patient_id = patients.id
        and appointments.doctor_id = auth.uid()
    )
    or exists (select 1 from receptionists r where r.id = auth.uid())
  );
create policy "patient self insert" on patients
  for insert with check (auth.uid() = id);

-- ── messages table (for chat consultation) ────────────────────────────────────
create table if not exists messages (
  id            uuid primary key default uuid_generate_v4(),
  appointment_id uuid references appointments(id) on delete cascade not null,
  sender_id     uuid references profiles(id) on delete cascade not null,
  text          text not null,
  created_at    timestamptz default now()
);

alter table messages enable row level security;

create policy "message parties" on messages for all using (
  exists (
    select 1 from appointments a
    where a.id = appointment_id
      and (auth.uid() = a.doctor_id or auth.uid() = a.patient_id)
  )
);

-- ── Real-time: enable for appointments and messages ───────────────────────────
alter publication supabase_realtime add table messages;
alter publication supabase_realtime add table appointments;
