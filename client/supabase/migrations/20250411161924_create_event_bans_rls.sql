alter table public.event_bans enable row level security;

create policy "Users can view their own bans" on public.event_bans
    for select
    to authenticated
    using (
        auth.uid() = user_id
    );

create policy "Users can create bans" on public.event_bans
    for insert
    to authenticated
    with check (
       auth.uid() = banned_by_user_id
    );

create policy "Moderator (user who banned) can delete bans" on public.event_bans
    for delete
    to authenticated
    using (
        auth.uid() = banned_by_user_id
    );
