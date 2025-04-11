create type event_status as enum ('upcoming', 'live', 'closing');

-- Events table

create table public.events (
    id bigint generated always as identity primary key,
    created_at timestamp with time zone default now(),
    updated_at timestamp with time zone default now(),
    title text not null,
    description text not null,
    image_paths text[] not null default array['default.event.thumbnail'],
    user_id uuid references auth.users on delete cascade not null,
    start timestamp with time zone not null,
    "end" timestamp with time zone not null,
    latitude double precision not null check (latitude >= -90 and latitude <= 90),
    longitude double precision not null check (longitude >= -180 and longitude <= 180),
    slot_limit integer not null check (slot_limit >= 1),
    age_restricted boolean not null default false,
    chat_enabled boolean not null default true,
    status event_status not null default 'upcoming'
);


comment on table public.events is 'All dropin events';
