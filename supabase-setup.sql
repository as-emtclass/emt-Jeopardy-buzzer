-- ============================================================
--  EMT JEOPARDY — one-time database setup (with admin auth)
-- ============================================================
--  Run this ONCE in your Supabase project:
--    Supabase Dashboard -> SQL Editor -> New query
--    Paste everything below -> click RUN.
--
--  Security model:
--    * Question banks are stored one row per quarter label.
--    * ANYONE (anon key) can READ banks  -> so the play/projection
--      screen (index.html) can load and display them with no login.
--    * Only a LOGGED-IN admin can INSERT / UPDATE / DELETE banks
--      -> editing happens only on admin.html after you sign in.
--  This means a student viewing the page source cannot change your
--  questions, because the anon key has no write permission.
-- ------------------------------------------------------------

create table if not exists public.jeopardy_boards (
  label       text primary key,
  board       jsonb not null,
  updated_at  timestamptz not null default now()
);

alter table public.jeopardy_boards enable row level security;

-- Clean up any policies from earlier setups
drop policy if exists "anon can read boards"    on public.jeopardy_boards;
drop policy if exists "anon can write boards"    on public.jeopardy_boards;
drop policy if exists "anon can update boards"   on public.jeopardy_boards;
drop policy if exists "anon can delete boards"   on public.jeopardy_boards;
drop policy if exists "public can read boards"   on public.jeopardy_boards;
drop policy if exists "authed can insert boards" on public.jeopardy_boards;
drop policy if exists "authed can update boards" on public.jeopardy_boards;
drop policy if exists "authed can delete boards" on public.jeopardy_boards;

-- READ: anyone (anon or logged-in) may read the question banks.
create policy "public can read boards"
  on public.jeopardy_boards for select
  to anon, authenticated using (true);

-- WRITE: only authenticated (logged-in admin) users.
create policy "authed can insert boards"
  on public.jeopardy_boards for insert
  to authenticated with check (true);

create policy "authed can update boards"
  on public.jeopardy_boards for update
  to authenticated using (true) with check (true);

create policy "authed can delete boards"
  on public.jeopardy_boards for delete
  to authenticated using (true);

-- ------------------------------------------------------------
--  CREATE YOUR ADMIN LOGIN
-- ------------------------------------------------------------
--  Do this in the dashboard (not SQL):
--    Authentication -> Users -> "Add user" -> enter your email +
--    a password, and (important) tick "Auto Confirm User" so you
--    can log in immediately without an email confirmation step.
--
--  OPTIONAL hardening: by default Supabase may allow self-sign-up.
--  Since only YOU should be an admin, turn that off:
--    Authentication -> Sign In / Providers (or Settings) ->
--    disable "Allow new users to sign up".
--  Then you remain the only account that can log in and edit banks.
-- ------------------------------------------------------------
