-- Add UPI ID field to doctors table
alter table doctors add column if not exists upi_id text;
