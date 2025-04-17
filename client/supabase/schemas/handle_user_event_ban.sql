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
    for each row execute procedure public.handle_user_event_ban();
