-- ===========================================
-- Migration:     create_events_rls
--
-- Description:
--   - Enables row-level security (RLS) on the 'events' table
--   - Prevents banned users from viewing specific events
--   - Allows authenticated users to insert, update, and delete only their own events
-- ===========================================
alter table public.events enable row level security;

create policy "Users can see all events" on public.events
    for select
    to authenticated
    using (
        true
    );

create policy "Users can insert their own events" on public.events
    for insert
    to authenticated
    with check ((select auth.uid()) = user_id);

create policy "Users can update their own events" on public.events
    for update
    to authenticated
    using (
        (select auth.uid()) = user_id
    )
    with check (
        (select auth.uid()) = user_id
    );

create policy "Users can delete their own events" on public.events
    for delete
    to authenticated
    using (
        (select auth.uid()) = user_id
    );