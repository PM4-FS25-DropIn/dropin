-- ===========================================
-- Migration:     create_event_joins_table
--
-- Description:
--   - Creates the 'event_joins' table to track event participants
--   - Links users to events, includes a timestamp and host flag
--   - Ensures uniqueness of each (event_id, user_id) pair
-- ===========================================
create table public.event_joins (
    id bigint generated always as identity primary key,
    event_id bigint references public.events on delete cascade not null,
    user_id uuid references auth.users on delete cascade not null,
    created_at timestamp with time zone not null default now(),
    is_host boolean not null default false,
    unique(event_id, user_id)
);

comment on table public.event_joins is 'Shows event participants';