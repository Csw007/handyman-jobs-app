-- Run this once in the Supabase SQL Editor (Project -> SQL Editor -> New query).
-- Sets up the two tables the app syncs through and locks both down to
-- signed-in users only (the publishable key alone grants no access).

create table if not exists jobs (
  id text primary key,
  data jsonb not null,
  deleted boolean not null default false,
  updated_at timestamptz not null default now()
);

alter table jobs enable row level security;

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

create policy "authenticated read/write intake"
  on intake for all
  to authenticated
  using (true)
  with check (true);
