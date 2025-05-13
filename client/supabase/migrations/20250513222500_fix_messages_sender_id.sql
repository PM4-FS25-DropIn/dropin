ALTER TABLE messages ALTER COLUMN sender_id TYPE UUID USING sender_id::uuid;
ALTER TABLE messages 
    ADD CONSTRAINT fk_sender 
    FOREIGN KEY (sender_id) 
    REFERENCES auth.users(id) 
    ON DELETE CASCADE;
