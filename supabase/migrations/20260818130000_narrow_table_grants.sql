-- ============================================================
--  MOGUL — take back the privileges nobody asked for
--
--  A Supabase project hands every new table in `public` to anon and
--  authenticated wholesale, through default privileges that run before
--  any grant written here. The narrow grants in the previous migration
--  therefore added nothing: `authenticated` still held DELETE, UPDATE
--  and TRUNCATE on the totals table.
--
--  Nothing could be damaged through them — no policy admits those
--  operations, so they matched zero rows and changed nothing. But that
--  left row-level security as the only lock on the door, and a silent
--  "0 rows" is a poor way to learn that. Taking the privileges back
--  makes the grants mean what they say: a policy added carelessly later
--  cannot open a door the role was never handed a key to.
-- ============================================================

revoke all on table public.profiles     from anon, authenticated;
revoke all on table public.game_results from anon, authenticated;
revoke all on table public.player_stats from anon, authenticated;

grant select, insert, update on table public.profiles     to authenticated;
grant select, insert         on table public.game_results to authenticated;
grant select                 on table public.player_stats to authenticated;
