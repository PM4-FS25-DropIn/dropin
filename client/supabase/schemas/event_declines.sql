create table public.event_declines (
    id bigint generated always as identity primary key,
    event_id bigint references events on delete cascade not null,
    user_id uuid references auth.users on delete cascade not null,
    created_at timestamp with time zone not null default now()
);

comment on table public.event_declines is 'Contains all events declined by users';