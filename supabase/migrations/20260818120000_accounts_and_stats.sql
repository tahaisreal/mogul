-- ============================================================
--  MOGUL — accounts and statistics
--
--  Three tables and one rule that shapes all of them: a player may
--  write down that a game happened, and may never write down how
--  many they have won. The totals are derived by a trigger the
--  client cannot reach, so "42 wins" means the rows are there.
--
--  Nothing here is auto-exposed: since April 2026 a new table is
--  invisible to the Data API until it is granted, so every grant
--  below is deliberate and kept to the minimum.
-- ============================================================

-- The trigger bodies live out of reach. A SECURITY DEFINER function
-- sitting in `public` is a callable endpoint for anyone; in here it
-- is only ever reached through the triggers that own it.
create schema if not exists private;
revoke all on schema private from public, anon, authenticated;


-- ---------- who you are ----------

create table public.profiles (
  id         uuid primary key references auth.users (id) on delete cascade,
  username   text not null,
  created_at timestamptz not null default now(),
  constraint username_shape check (username ~ '^[A-Za-z0-9 _.-]{2,14}$')
);

-- "taha" and "Taha" are the same person to everyone reading the board,
-- so they are the same name to the database too.
create unique index profiles_username_key on public.profiles (lower(username));

alter table public.profiles enable row level security;

grant select         on table public.profiles to authenticated;
grant insert, update on table public.profiles to authenticated;

create policy "profiles are readable by signed-in players"
  on public.profiles for select
  to authenticated
  using (true);

create policy "a player creates only their own profile"
  on public.profiles for insert
  to authenticated
  with check ((select auth.uid()) = id);

-- both halves matter: without WITH CHECK a player could hand their row
-- to somebody else's id on the way out
create policy "a player renames only themselves"
  on public.profiles for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);


-- ---------- what happened ----------

create table public.game_results (
  id          bigint generated always as identity primary key,
  player_id   uuid not null references public.profiles (id) on delete cascade,
  game_id     text not null check (length(game_id) between 4 and 40),
  won         boolean not null,
  players     smallint not null check (players between 2 and 12),
  teams       boolean not null default false,
  finished_at timestamptz not null default now(),
  -- the end of a game is broadcast over and over; recording it twice
  -- would inflate every total, so the same game can only land once
  unique (player_id, game_id)
);

create index game_results_player_finished_idx
  on public.game_results (player_id, finished_at desc);

alter table public.game_results enable row level security;

-- insert and select only: a result that has been written cannot be
-- edited or withdrawn, by anyone, including the player it belongs to
grant select, insert on table public.game_results to authenticated;

create policy "results are readable by signed-in players"
  on public.game_results for select
  to authenticated
  using (true);

create policy "a player records only their own result"
  on public.game_results for insert
  to authenticated
  with check ((select auth.uid()) = player_id);


-- ---------- what it adds up to ----------

create table public.player_stats (
  player_id      uuid primary key references public.profiles (id) on delete cascade,
  games_played   integer not null default 0,
  games_won      integer not null default 0,
  current_streak integer not null default 0,
  best_streak    integer not null default 0,
  updated_at     timestamptz not null default now()
);

alter table public.player_stats enable row level security;

-- Read, and only read. There is deliberately no insert/update/delete
-- grant and no policy for them: the trigger below is the only writer,
-- which is what stops a browser from simply declaring itself champion.
grant select on table public.player_stats to authenticated;

create policy "stats are readable by signed-in players"
  on public.player_stats for select
  to authenticated
  using (true);


-- ---------- the only writer ----------

create function private.apply_game_result()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.player_stats as st
    (player_id, games_played, games_won, current_streak, best_streak, updated_at)
  values
    (new.player_id, 1,
     case when new.won then 1 else 0 end,
     case when new.won then 1 else 0 end,
     case when new.won then 1 else 0 end,
     now())
  on conflict (player_id) do update set
    games_played   = st.games_played + 1,
    games_won      = st.games_won + case when new.won then 1 else 0 end,
    current_streak = case when new.won then st.current_streak + 1 else 0 end,
    best_streak    = greatest(st.best_streak,
                              case when new.won then st.current_streak + 1 else 0 end),
    updated_at     = now();
  return new;
end;
$$;

revoke all on function private.apply_game_result() from public, anon, authenticated;

create trigger apply_game_result
  after insert on public.game_results
  for each row execute function private.apply_game_result();


-- ---------- a profile for every new account ----------

create function private.create_profile_for_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  wanted    text := nullif(trim(new.raw_user_meta_data ->> 'username'), '');
  candidate text;
  stem      text;
begin
  -- The name is a label, never a permission, so taking it from the
  -- signup metadata is safe; the shape is still forced here.
  candidate := coalesce(wanted, 'Player');
  candidate := left(regexp_replace(candidate, '[^A-Za-z0-9 _.-]', '', 'g'), 14);
  candidate := trim(candidate);
  if length(candidate) < 2 then
    candidate := 'Player';
  end if;
  stem := left(candidate, 9);
  if length(stem) < 2 then
    stem := 'Player';
  end if;

  -- First come, first served. Somebody else holding the name should
  -- cost a suffix, never a failed signup.
  for attempt in 0..40 loop
    begin
      insert into public.profiles (id, username)
      values (new.id,
              case when attempt = 0 then candidate
                   else stem || floor(random() * 9000 + 1000)::text end);
      return new;
    exception when unique_violation then
      if attempt = 40 then raise; end if;
    end;
  end loop;
  return new;
end;
$$;

revoke all on function private.create_profile_for_new_user() from public, anon, authenticated;

create trigger create_profile_for_new_user
  after insert on auth.users
  for each row execute function private.create_profile_for_new_user();
