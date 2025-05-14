-- ===========================================
-- Migration:     drop_session_name
--
-- Description:
--   This migration modifies the messages table by removing the session_name column.
-- ===========================================

ALTER TABLE messages DROP COLUMN session_name;
