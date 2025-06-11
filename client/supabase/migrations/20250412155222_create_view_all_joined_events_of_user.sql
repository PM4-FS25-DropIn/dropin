create or replace view public.events_joined_by_user as 
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
join public.event_joins ej on ej.event_id = e.id
where auth.uid() = ej.user_id;