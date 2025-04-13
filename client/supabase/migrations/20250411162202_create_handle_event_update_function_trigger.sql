-- ===========================================
-- Migration:     create_handle_event_update_function_trigger
--
-- Description:
--   - Creates a trigger function that automatically updates the
--     'updated_at' timestamp on the 'events' table whenever a row is modified
--   - Trigger runs before any update on the table
-- ===========================================
create function handle_event_update()
returns trigger
set search_path = ''
as $$
begin
    new.updated_at := CURRENT_TIMESTAMP;
    return new;
end;
$$ language plpgsql security definer;
create trigger on_event_update
    before update on public.events
    for each row execute function handle_event_update();
