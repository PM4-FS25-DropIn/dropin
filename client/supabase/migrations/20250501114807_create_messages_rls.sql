-- ===========================================
-- Migration:     create_messages_rls
--
-- Description:
--   This migration adds row level security policies to the messages table.
-- ===========================================

alter table "public"."messages" enable row level security;

create policy "Anyone can insert messages"
on "public"."messages"
as permissive
for insert
to authenticated, anon
with check (true);


create policy "Anyone can read messages"
on "public"."messages"
as permissive
for select
to authenticated, anon
using (true);