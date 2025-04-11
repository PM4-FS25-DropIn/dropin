alter table public.event_joins enable row level security;

create policy "Users can view joined events" on public.event_joins
    for select
    to authenticated
    using (
        auth.uid() = user_id
    );

create policy "Users can leave events" on public.event_joins
    for delete
    to authenticated
    using (
        auth.uid() = user_id
    );
