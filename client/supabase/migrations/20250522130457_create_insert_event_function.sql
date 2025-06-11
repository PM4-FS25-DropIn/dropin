-- ===========================================
-- Migration:     create_insert_event_function (fixed ambiguous id)
-- Description:   Inserts a DropInEvent from one JSONB payload,
--                returning JSONB location and disambiguating columns
-- ===========================================
create or replace function public.insert_event(
  event jsonb
)
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
language plpgsql
as $$
begin
  return query
    -- give the table an alias `e`
    insert into public.events as e
      ( title
      , description
      , image_paths
      , start
      , "end"
      , slot_limit
      , age_restricted
      , chat_enabled
      , location
      )
    values
      ( event->>'title'
      , event->>'description'
      , ARRAY(select jsonb_array_elements_text(event->'image_paths'))
      , (event->>'start')::timestamptz
      , (event->>'end')::timestamptz
      , (event->>'slot_limit')::int
      , (event->>'age_restricted')::bool
      , (event->>'chat_enabled')::bool
      , ST_SetSRID(
          ST_GeomFromGeoJSON((event->'location')::text),
          4326
        )::geography
      )
    -- qualify every column with `e.` so Postgres knows you mean the table columns
    returning
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
      ST_AsGeoJSON(e.location)::jsonb as location;
end;
$$;