-- ===========================================
-- Migration:     create_handle_event_creation_function_trigger
--
-- Description:
--   - Creates a trigger function that automatically adds the event creator
--     to the 'event_joins' table as the host when a new event is created
--   - Trigger runs after insert on the 'events' table
-- ===========================================
create function public.handle_event_creation_autojoin()
returns trigger
set search_path = ''
as $$
begin
	insert into public.event_joins (event_id, user_id, is_host)
	values (new.id, new.user_id, true);
	return new;
end;

$$ language plpgsql security definer;
create trigger on_new_event_created_autojoin
	after insert on public.events
	for each row execute function handle_event_creation_autojoin();
