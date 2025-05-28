-- ===========================================
-- Migration:     Create Banner Bucket
--
-- Description:
-- Create the storage bucket for the banner pics.
-- 
--  
-- ==========================================

insert into storage.buckets
(id, name, public)
values
('banners', 'banners', true)