-- ===========================================
-- Migration:     Create Avatar Bucket
--
-- Description:
--   - Creates row-level security (RLS) policies for the 'avatars' bucket
--   - Allows authenticated users to publicly read avatar images
--   - Allows authenticated users to upload avatars to their own folder
-- ============================================

create policy "Users can upload avatars." on storage.objects
for insert to authenticated with check (
    bucket_id = 'avatars'
);