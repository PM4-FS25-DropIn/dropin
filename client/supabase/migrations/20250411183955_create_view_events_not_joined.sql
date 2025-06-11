create or replace view public.events_not_joined as
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
where e.user_id != auth.uid()
and not exists (
    select 1 
    from public.event_joins ej
    where ej.event_id = e.id and ej.user_id = auth.uid()
);