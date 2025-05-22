-- ===========================================
-- Migration:     create_get_joined_events_function
-- Description:   Returns all events the current user has joined,
--                emitting `location` as JSON for your GeoJSONPoint.
-- ===========================================

create or replace function public.get_joined_events_of_user()
returns table (
    id             bigint,
    created_at     timestamp with time zone,
    updated_at     timestamp with time zone,
    title          text,
    description    text,
    image_paths    text[],
    user_id        uuid,
    start          timestamp with time zone,
    "end"          timestamp with time zone,
    slot_limit     integer,
    slots_taken    integer,
    age_restricted boolean,
    chat_enabled   boolean,
    location       jsonb
)
language sql stable
as $$
    select
      e.id,
      e.created_at,
      e.updated_at,
      e.title,
      e.description,
      e.image_paths,
      e.user_id,
      e.start,
      e."end",
      e.slot_limit,
      e.slots_taken,
      e.age_restricted,
      e.chat_enabled,
      ST_AsGeoJSON(e.location)::jsonb as location
    from public.events e
    join public.event_joins ej
      on ej.event_id = e.id
    where ej.user_id = auth.uid();
$$;