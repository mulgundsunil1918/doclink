-- Migration 008: per-consultation-type fees set by the doctor
-- Run in Supabase SQL Editor → New Query → Run
--
-- Fees for video/audio/chat/in-person were derived from consultation_fee by
-- fixed multipliers (1.0 / 0.75 / 0.5 / 0.5) hardcoded in the client. A doctor
-- who charges more for a chat follow-up than an audio call, or who does not
-- offer video at all, had no way to say so.
--
-- These columns are nullable on purpose: NULL means "derive it from the base
-- fee as before", so every existing doctor keeps their current pricing and only
-- the ones who edit a rate get an explicit value.

alter table doctors
  add column if not exists fee_video     numeric(10,2),
  add column if not exists fee_audio     numeric(10,2),
  add column if not exists fee_chat      numeric(10,2),
  add column if not exists fee_in_person numeric(10,2);

-- A fee may be zero (a doctor offering free follow-up chats) but never
-- negative, and the ceiling is a guard against a slipped decimal point.
do $$ begin
  alter table doctors
    add constraint doctors_fees_nonnegative check (
      coalesce(fee_video,     0) between 0 and 1000000 and
      coalesce(fee_audio,     0) between 0 and 1000000 and
      coalesce(fee_chat,      0) between 0 and 1000000 and
      coalesce(fee_in_person, 0) between 0 and 1000000
    );
exception when duplicate_object then null;
end $$;

comment on column doctors.fee_video is
  'Explicit video consultation fee. NULL derives from consultation_fee.';
comment on column doctors.fee_audio is
  'Explicit audio consultation fee. NULL derives from consultation_fee.';
comment on column doctors.fee_chat is
  'Explicit chat consultation fee. NULL derives from consultation_fee.';
comment on column doctors.fee_in_person is
  'Explicit in-person consultation fee. NULL derives from consultation_fee.';
