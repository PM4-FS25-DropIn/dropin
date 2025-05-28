-- ===========================================
-- Migration:     add_messages_primary_key
--
-- Description:
--   This migration adds a primary key to the messages table.
-- ===========================================

ALTER TABLE messages ADD PRIMARY KEY (id);