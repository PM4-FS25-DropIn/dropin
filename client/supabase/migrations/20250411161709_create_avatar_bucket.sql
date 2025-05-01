-- ===========================================
-- Migration:     Create Avatar Bucket
--
-- Description:
-- Create the storage bucket for the avatar profile pics.
-- 
--  
-- ==========================================

insert into storage.buckets
(id, name, public)
values
('avatars', 'avatars', true);