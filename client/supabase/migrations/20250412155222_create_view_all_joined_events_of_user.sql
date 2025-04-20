-- ===========================================
-- Migration:     create_view_all_joined_events_of_user
--
-- Description:
--   - Creates a view 'events_joined_by_user' that lists all events
--     the currently authenticated user has joined
--   - Joins 'events' with 'event_joins' and filters by auth.uid()
-- ===========================================
create view public.events_joined_by_user as 
select e.* from public.events e
join public.event_joins ej on ej.event_id = e.id
where auth.uid() = ej.user_id;