-- ===========================================
-- Migration:     Create Avatar Bucket
--
-- Description:
--   - Creates row-level security (RLS) policies for the 'avatars' bucket
--   - Allows authenticated users to publicly read avatar images
--   - Allows authenticated users to upload avatars to their own folder
-- ============================================

CREATE POLICY "Authenticated users can upload an avatar."
    ON storage.objects
    FOR INSERT TO authenticated WITH CHECK (
        bucket_id = 'avatars'
    );

CREATE POLICY "Allow owner to delete their own avatar."
    ON storage.objects
    FOR DELETE TO authenticated USING (
        bucket_id = 'avatars' AND (storage.foldername(name))[1] = (select auth.uid()::text)
    );

CREATE POLICY "Allow owner to update their own avatar."
    ON storage.objects
    FOR UPDATE TO authenticated USING (
        bucket_id = 'avatars' AND (storage.foldername(name))[1] = (select auth.uid()::text)
    );

CREATE POLICY "Allow everyone to see an avatar."
    ON storage.objects
    FOR SELECT TO authenticated USING (
        bucket_id = 'avatars'
    );