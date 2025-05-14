-- ===========================================
-- Migration:     fix_messages_sender_id
--
-- Description:
--   This migration fixes the sender_id column in the messages table by
--   changing its type to UUID and adding a foreign key constraint.
-- ===========================================

ALTER TABLE messages ALTER COLUMN sender_id TYPE UUID USING sender_id::uuid;
ALTER TABLE messages 
    ADD CONSTRAINT fk_sender 
    FOREIGN KEY (sender_id) 
    REFERENCES auth.users(id) 
    ON DELETE CASCADE;
