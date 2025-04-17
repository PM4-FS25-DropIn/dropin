-- ===========================================
-- Migration:     create_event_bans_table
--
-- Description:
--   - Creates the 'event_bans' table to track users banned from events
--   - Stores which user was banned, by whom, and when
--   - Ensures uniqueness per (event_id, user_id) to prevent duplicates
-- ===========================================
create table public.event_bans (
    id bigint generated always as identity primary key,
    event_id bigint references public.events on delete cascade not null,
    user_id uuid references auth.users on delete cascade not null,
    banned_by_user_id uuid references auth.users on delete cascade not null,
    created_at timestamp with time zone not null default now(),
    unique(event_id, user_id)
);

comment on table public.event_bans is 'Contains all user bans for events';