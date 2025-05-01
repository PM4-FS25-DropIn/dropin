-- ===========================================
-- Migration:     Create Profiles Table
--
-- Description:
-- Creates the profiles table in the public schema which allows
-- to retrieve data, username and avatar urls easily.  
--  
-- ===========================================
create table public.profiles (
    id uuid references auth.users on delete cascade primary key,
    updated_at timestamp with time zone not null default now(),
    username text not null unique,
    avatar_url text,
    constraint username check (char_length(username) >= 3)
);

comment on table public.profiles is 'Profiles table of users.';