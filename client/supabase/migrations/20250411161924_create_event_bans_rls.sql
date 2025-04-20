-- ===========================================
-- Migration:     create_event_bans_rls
--
-- Description:
--   - Enables row-level security (RLS) on the 'event_bans' table
--   - Allows users to view bans applied to them
--   - Allows authenticated users to create bans where they are the banner
--   - Allows users to delete bans they themselves created
-- ===========================================
alter table public.event_bans enable row level security;

create policy "Users can view their own bans" on public.event_bans
    for select
    to authenticated
    using (
        (select auth.uid()) = user_id
    );

create policy "Users can create bans" on public.event_bans
    for insert
    to authenticated
    with check (
       (select auth.uid()) = banned_by_user_id
    );

create policy "Moderator (user who banned) can delete bans" on public.event_bans
    for delete
    to authenticated
    using (
        (select auth.uid()) = banned_by_user_id
    );
