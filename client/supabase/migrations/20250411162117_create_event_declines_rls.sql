-- ===========================================
-- Migration:     create_event_declines_rls
--
-- Description:
--   - Enables row-level security (RLS) on the 'event_declines' table
--   - Allows users to:
--       • View their own declined events
--       • Decline events as themselves (auth.uid must match user_id)
-- ===========================================
alter table public.event_declines enable row level security;

create policy "Users can view declined events" on public.event_declines
    for select
    to authenticated
    using (
    (select auth.uid()) = user_id
    );

create policy "Users can decline events" on public.event_declines
    for insert
    to authenticated
    with check (
    (select auth.uid()) = user_id
    );

    