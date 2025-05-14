ALTER TABLE messages DROP COLUMN session_name;
ALTER TABLE messages ALTER COLUMN sender_id TYPE uuid USING sender_id::uuid;
ALTER TABLE messages ADD FOREIGN KEY (sender_id) REFERENCES auth.users(id);