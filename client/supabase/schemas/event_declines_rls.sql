alter table public.event_declines enable row level security;

create policy "Users can view declined events" on public.event_declines
    for select
    to authenticated
    using (
    auth.uid() = user_id
    );

create policy "Users can decline events" on public.event_declines
    for insert
    to authenticated
    with check (
    auth.uid() = user_id
    );

    