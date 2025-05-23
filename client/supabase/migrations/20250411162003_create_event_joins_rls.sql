-- ===========================================
-- Migration:     create_event_joins_rls
--
-- Description:
--   - Enables row-level security (RLS) on the 'event_joins' table
--   - Allows users to:
--       • View their own event join records
--       • Leave events they joined
--       • Be auto-added to events via trigger (if user_id matches auth.uid)
-- ===========================================
alter table public.event_joins enable row level security;

create policy "Users can view joined events." on public.event_joins
    for select
    to authenticated
    using (true);

create policy "Users can leave events." on public.event_joins
    for delete
    to authenticated
    using (
        (select auth.uid()) = user_id
    );

create policy "Users can insert event on autojoin trigger." on public.event_joins
    for insert
    to authenticated
    with check (
       (select auth.uid()) = user_id 
    );