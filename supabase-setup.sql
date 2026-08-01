-- Run this in the Supabase SQL Editor (Project -> SQL Editor -> New query).
-- Sets up the tables the app syncs through and locks them all down to
-- signed-in users only (the publishable key alone grants no access).
-- Safe to run more than once if an earlier attempt got partway through.

create table if not exists jobs (
  id text primary key,
  data jsonb not null,
  deleted boolean not null default false,
  updated_at timestamptz not null default now()
);

alter table jobs enable row level security;

drop policy if exists "authenticated read/write jobs" on jobs;
create policy "authenticated read/write jobs"
  on jobs for all
  to authenticated
  using (true)
  with check (true);

-- Handoff queue: office intake writes here, the phone drains it and
-- deletes what it's absorbed. Not a permanent record on its own.
create table if not exists intake (
  id text primary key,
  data jsonb not null,
  created_at timestamptz not null default now()
);

alter table intake enable row level security;

drop policy if exists "authenticated read/write intake" on intake;
create policy "authenticated read/write intake"
  on intake for all
  to authenticated
  using (true)
  with check (true);

-- Shared client list, used to populate the "Client" dropdown on both the
-- phone and office pages.
create table if not exists clients (
  id text primary key,
  data jsonb not null,
  deleted boolean not null default false,
  updated_at timestamptz not null default now()
);

alter table clients enable row level security;

drop policy if exists "authenticated read/write clients" on clients;
create policy "authenticated read/write clients"
  on clients for all
  to authenticated
  using (true)
  with check (true);
