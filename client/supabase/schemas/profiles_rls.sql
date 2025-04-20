-- RLS

alter table profiles enable row level security;

-- Policy for select
create policy "Public profiles are viewable by everyone." on public.profiles
    for select
    to authenticated
    using (true);

-- Policy for insert
create policy "Users can insert their own profile." on public.profiles
    for insert
    to authenticated
    with check
    ((select auth.uid()) = id);

-- Policy for update
create policy "Users can update their own profile." on public.profiles
    for update
    to authenticated
    using ((select auth.uid()) = id);