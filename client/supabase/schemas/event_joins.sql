create table public.event_joins (
    id bigint generated always as identity primary key,
    event_id bigint references public.events on delete cascade not null,
    user_id uuid references auth.users on delete cascade not null,
    created_at timestamp with time zone not null default now(),
    is_host boolean not null default false
);

comment on table public.event_joins is 'Shows event participants';