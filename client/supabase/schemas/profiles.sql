-- Table
create table public.profiles (
    id uuid references auth.users on delete cascade primary key,
    updated_at timestamp with time zone default now(),
    username text unique,
    avatar_url text,
    constraint username check (char_length(username) >= 3)
);

comment on table public.profiles is 'Profiles table of users.';