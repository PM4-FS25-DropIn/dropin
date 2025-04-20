create function handle_event_update()
returns trigger
set search_path = ''
as $$
begin
    new.updated_at = CURRENT_TIMESTAMP;
    return new;
end;
$$ language plpgsql security definer;
create trigger on_event_update
    before update on public.events
    for each row execute procedure handle_event_update();
