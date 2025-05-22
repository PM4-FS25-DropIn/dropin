create or replace function public.update_event(event jsonb)
returns void
language plpgsql
as $$
begin
  update public.events
  set
    title = event->>'title',
    description = event->>'description',
    image_paths = ARRAY(select jsonb_array_elements_text(event->'image_paths')),
    start = (event->>'start')::timestamptz,
    "end" = (event->>'end')::timestamptz,
    slot_limit = (event->>'slot_limit')::int,
    age_restricted = (event->>'age_restricted')::bool,
    chat_enabled = (event->>'chat_enabled')::bool,
    location = ST_SetSRID(
      ST_GeomFromGeoJSON((event->'location')::text),
      4326
    )::geography,
    updated_at = now()
  where id = (event->>'id')::bigint;
end;
$$;