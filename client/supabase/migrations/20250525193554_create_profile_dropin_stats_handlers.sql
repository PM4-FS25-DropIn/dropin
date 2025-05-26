-- ===========================================
-- Migration:     create_dropinsCount_handlers
--
-- Description:
--   - Creates trigger functions to update the 'dropins_created' and 'dropins_joined'
--     counters on the 'profiles' table.
--   - 'increment_dropins_created' runs after a new row is added to 'events'
--   - 'increment_dropins_joined' runs after a new row is added to 'event_joins'
-- ===========================================

-- Increment dropins_created when a new event is created
create function increment_dropins_created()
returns trigger
set search_path = ''
as $$
begin
    update public.profiles
    set dropins_created = dropins_created + 1
    where id = new.user_id;
    return new;
end;
$$ language plpgsql security definer;

-- Increment dropins_joined when a user joins an event
create function increment_dropins_joined()
returns trigger
set search_path = ''
as $$
begin
    update public.profiles
    set dropins_joined = dropins_joined + 1
    where id = new.user_id; -- assumes event_joins.user_id = profiles.id
    return new;
end;
$$ language plpgsql security definer;

-- Trigger for when an event is created
create trigger on_event_created
after insert on public.events
for each row
execute function increment_dropins_created();

-- Trigger for when a user joins an event
create trigger on_event_joined
after insert on public.event_joins
for each row
execute function increment_dropins_joined();