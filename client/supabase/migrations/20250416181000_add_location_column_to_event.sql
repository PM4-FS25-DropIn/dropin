-- ===========================================
-- Migration:     add_location_column_to_event
--
-- Description:
--  Adds postgis extension to the public schema.
--  Adds a location column to the events table, which is a geography point type.
--  The column is populated with the existing latitude and longitude values
--  The check constraints for latitude and longitude are dropped.
--  The latitude and longitude columns are then dropped.
--  The location column is set to not null.
-- ===========================================
CREATE EXTENSION IF NOT EXISTS postgis SCHEMA public;

-- We need to drop the function and the view,
-- since postgresql does not allow to alter views...
drop function fetch_events_feed;

drop view public.events_not_responded_to;
drop view public.events_joined_by_user;

-- now we can drop the constraints of the columns
alter table events drop constraint events_latitude_check;
alter table events drop constraint events_longitude_check;

-- add the new column and migrate existing columns
alter table public.events ADD COLUMN location geography(Point, 4326);
update public.events SET location = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography;

-- mark location as not nullable
alter table public.events alter column location set not null;

-- finally, we can drop the old columns
alter table public.events drop column latitude;
alter table public.events drop column longitude;

-- recreate the views. We explizitly name all the columns we want.
create or replace view public.events_not_responded_to as
    select * from public.events e 
          where e.user_id != auth.uid()
          and not exists (
            select 1 
            from public.event_joins ej
            where ej.event_id = e.id and ej.user_id = auth.uid()
            )
          and not exists (
            select 1 
            from public.event_declines ed
            where ed.event_id = e.id and ed.user_id = auth.uid()
        );

create view public.events_joined_by_user as 
    select e.* from public.events e
    join public.event_joins ej on ej.event_id = e.id
    where auth.uid() = ej.user_id;

-- recreate the function.
create or replace function fetch_events_feed(excluded_ids int[])
returns setof events_not_responded_to
language sql
as $$
    select *
    from events_not_responded_to
    where id != all(excluded_ids)
    limit 5;
$$;