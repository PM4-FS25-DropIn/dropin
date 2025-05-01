-- ===========================================
-- Migration:     create_messages_realtime
--
-- Description:
--   This migration adds the messages table to the supabase_realtime publication.
-- ===========================================

alter publication supabase_realtime add table messages;