-- ===========================================
-- Migration:     create_view_events_not_responded_to
--
-- Description:
--   - Creates a view listing all events the authenticated user
--     has not yet responded to (neither joined nor declined)
--   - Excludes events created by the user themselves
-- ===========================================
create view public.events_not_joined as
select e.* from public.events e 
where e.user_id != auth.uid()
and not exists (
    select 1 
    from public.event_joins ej
    where ej.event_id = e.id and ej.user_id = auth.uid()
);
