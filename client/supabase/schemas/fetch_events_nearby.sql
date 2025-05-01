create or replace function fetch_events_nearby(
  user_lat double precision,
  user_lng double precision,
  radius_meters double precision
)
returns setof events as $$
begin
  return query
  select *
  from events
  where ST_DWithin(
    ST_MakePoint(longitude, latitude)::geography,
    ST_MakePoint(user_lng, user_lat)::geography,
    radius_meters
  );
end;
$$ language plpgsql security definer;