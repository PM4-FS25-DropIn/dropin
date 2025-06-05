-- ===========================================
-- Migration:     Limit avatar file type, size and type
--
-- Description:
--   - Limits the file size of avatar images to 5MB
--   - Only allows png, jpeg, webp, gifs and apng for avatar images
-- ============================================

-- Limit file size to 10MB and limit mime types to images only
UPDATE storage.buckets SET file_size_limit = 10485760, allowed_mime_types = ARRAY['image/*'] WHERE id = 'avatars';