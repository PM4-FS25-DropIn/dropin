-- ===========================================
-- Migration:     create_messages_tables
--
-- Description:
--   This migration creates the messages table.
--   It includes the following columns:
--   - id: UUID, primary key, default value is generated using gen_random_uuid()
--   - sender_id: text, not null
--   - session_name: text, not null
--   - content: text, not null
--   - created_at: timestamp with time zone, not null, default value is the current time in UTC
--   - chat_room_id: bigint
-- ===========================================


create table "public"."messages" (
    "id" uuid not null default gen_random_uuid(),
    "sender_id" text not null,
    "session_name" text not null,
    "content" text not null,
    "created_at" timestamp with time zone not null default timezone('utc'::text, now()),
    "chat_room_id" bigint references public.events on delete cascade not null,
);

