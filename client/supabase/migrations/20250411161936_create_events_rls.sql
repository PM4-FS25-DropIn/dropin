alter table public.events enable row level security;

create policy "Users can select non-banned events" on public.events
    for select
    to authenticated
    using (
        not exists (
        select 1 from public.event_bans eb
        where eb.event_id = id
        and eb.user_id = auth.uid()
        )
    );

create policy "Users can insert their own events" on public.events
    for insert
    to authenticated
    with check (auth.uid() = user_id);

create policy "Users can update their own events" on public.events
    for update
    to authenticated
    using (
        auth.uid() = user_id
    )
    with check (
        auth.uid() = user_id
    );

create policy "Users can delete their own events" on public.events
    for delete
    to authenticated
    using (
        auth.uid() = user_id
    );