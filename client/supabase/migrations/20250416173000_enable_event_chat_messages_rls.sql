-- ===========================================
-- Migration:     create_event_chat_messages_table
--
-- Description:
--   - Enables row level security on the event_chat_messages table
-- ===========================================

ALTER TABLE public.event_chat_messages ENABLE ROW LEVEL SECURITY;