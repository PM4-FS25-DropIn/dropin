create or replace function public.get_events_in_region(
    center_lat   double precision,
    center_lon   double precision,
    lat_delta    double precision,
    lon_delta    double precision
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
language sql stable
as $$
with bounds as (
  select
    center_lat - lat_delta/2 as min_lat,
    center_lat + lat_delta/2 as max_lat,
    center_lon - lon_delta/2 as min_lon,
    center_lon + lon_delta/2 as max_lon
),
box as (
  select ST_MakeEnvelope(
           min_lon, min_lat,
           max_lon, max_lat,
           4326
         )::geometry as geom
  from bounds
)
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
cross join box
where ST_Within(e.location::geometry, box.geom);
$$;