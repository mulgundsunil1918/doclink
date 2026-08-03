-- Migration 007: doctor-direct UPI payments + platform subscriptions
-- Run in Supabase SQL Editor → New Query → Run
--
-- Model change: the doctor is paid directly into their own UPI account. The
-- platform never receives patient money and takes no per-consultation cut —
-- the only revenue is the doctor's subscription.

-- ── Doctor payout identity ───────────────────────────────────────────────────
-- upi_id was added in 004; upi_name is the payee name shown inside the
-- patient's UPI app so they can confirm who they are paying before sending.
alter table doctors add column if not exists upi_id   text;
alter table doctors add column if not exists upi_name text;

-- ── Subscription: the platform's only revenue ────────────────────────────────
do $$ begin
  create type subscription_plan as enum ('trial', 'free', 'pro');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type subscription_state as enum ('active', 'lapsed');
exception when duplicate_object then null;
end $$;

alter table doctors
  add column if not exists plan            subscription_plan  not null default 'trial',
  add column if not exists plan_state      subscription_state not null default 'active',
  add column if not exists plan_expires_at timestamptz        default (now() + interval '30 days');

-- ── UPI-direct payment tracking ──────────────────────────────────────────────
-- Money moves patient → doctor's bank with no gateway in between, so there is
-- no webhook to confirm it. The patient submits the UTR from their UPI app and
-- the doctor confirms the credit actually landed.
alter table payments
  add column if not exists upi_txn_ref        text,
  add column if not exists upi_utr            text,
  add column if not exists paid_to_upi_id     text,
  add column if not exists verified_by_doctor boolean default false,
  add column if not exists verified_at        timestamptz;

create index if not exists payments_pending_verify_idx
  on payments (verified_by_doctor, status);

-- ── Read-only lockout when a subscription lapses ─────────────────────────────
-- A lapsed doctor keeps full READ access to their existing patients, records
-- and prescriptions. They simply cannot create new ones until they renew.
-- Expiry is evaluated inline, so a subscription lapses on its own without
-- needing a scheduled sweeper job.
create or replace function doctor_is_active(p_doctor uuid)
returns boolean language sql stable security definer as $$
  select coalesce(
    (select plan_state = 'active'
        and (plan_expires_at is null or plan_expires_at > now())
       from doctors where id = p_doctor),
    false
  );
$$;

-- New prescriptions require an active subscription.
drop policy if exists "doctor writes rx" on prescriptions;
create policy "doctor writes rx" on prescriptions for insert with check (
  auth.uid() = doctor_id and doctor_is_active(doctor_id)
);

drop policy if exists "doctor writes medicine" on medicines;
create policy "doctor writes medicine" on medicines for insert with check (
  exists (
    select 1 from prescriptions p
    where p.id = prescription_id
      and auth.uid() = p.doctor_id
      and doctor_is_active(p.doctor_id)
  )
);

-- New bookings cannot be made against a lapsed doctor.
drop policy if exists "patient books" on appointments;
create policy "patient books" on appointments for insert with check (
  auth.uid() = patient_id and doctor_is_active(doctor_id)
);

drop policy if exists "receptionist books" on appointments;
create policy "receptionist books" on appointments for insert with check (
  exists (select 1 from receptionists r where r.id = auth.uid())
  and doctor_is_active(doctor_id)
);

-- ── Doctor confirms a UPI payment landed ─────────────────────────────────────
-- payments had no update policy at all, so verification was impossible.
drop policy if exists "doctor verifies payment" on payments;
create policy "doctor verifies payment" on payments for update using (
  exists (
    select 1 from appointments a
    where a.id = appointment_id and auth.uid() = a.doctor_id
  )
)
-- Without a with-check the doctor could rewrite appointment_id and move a
-- payment onto someone else's appointment. Re-assert ownership on the new row.
with check (
  exists (
    select 1 from appointments a
    where a.id = appointment_id and auth.uid() = a.doctor_id
  )
);
