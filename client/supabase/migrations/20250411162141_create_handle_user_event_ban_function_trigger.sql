-- ===========================================
-- Migration:     create_handle_user_event_ban_function_trigger
--
-- Description:
--   - Creates a trigger function that removes a user from 'event_joins'
--     when they are banned from an event
--   - Trigger runs after insert on 'event_bans' table
-- ===========================================
create function handle_user_event_ban()
returns trigger
set search_path = ''
as $$
begin
    delete from public.event_joins
    where user_id = NEW.user_id
    and event_id = NEW.event_id;

    return NEW;
end;
$$ language plpgsql security definer;
create trigger on_user_event_ban
    after insert on public.event_bans
    for each row execute function public.handle_user_event_ban();
