-- ===========================================
-- Migration:     create_event_feed_fetch_function
--
-- Description:
--   - Creates the 'fetch_events_feed' SQL function
--   - Returns up to 5 events the user has not responded to
--     and filters out any events with IDs in the excluded_ids array
-- ===========================================
create or replace function fetch_events_feed(excluded_ids int[])
returns setof public.events_not_joined
language sql
as $$
    select *
    from public.events_not_joined
    where id != all(excluded_ids)
    limit 5;
$$;