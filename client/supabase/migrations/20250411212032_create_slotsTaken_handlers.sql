-- ===========================================
-- Migration:     create_slotsTaken_handlers
--
-- Description:
--   - Creates trigger functions to update the 'slots_taken' counter
--     on the 'events' table when users join or leave events
--   - 'increment_slots_taken' runs after a new row is added to 'event_joins'
--   - 'decrement_slots_taken' runs after a row is deleted from 'event_joins'
-- ===========================================
create function increment_slots_taken() 
returns trigger
set search_path = ''
as $$
begin
    update public.events
    set slots_taken = slots_taken + 1
    where id = new.event_id;
    return new;
end;
$$ language plpgsql security definer;

create function decrement_slots_taken()
returns trigger
set search_path = ''
as $$
begin
    update public.events
    set slots_taken = slots_taken - 1
    where id = old.event_id;
    return old;
end;
$$ language plpgsql security definer;

create trigger on_new_event_joined
after insert on public.event_joins
for each row
execute function increment_slots_taken();


create trigger on_new_event_leave
after delete on public.event_joins
for each row
execute function decrement_slots_taken();
