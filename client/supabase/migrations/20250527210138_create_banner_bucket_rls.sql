-- ===========================================
-- Migration:     Create Banner Bucket
--
-- Description:
--   - Creates row-level security (RLS) policies for the 'banner' bucket
--   - Allows authenticated users to publicly read banner images
--   - Allows authenticated users to upload banner to their own folder
-- ============================================

CREATE POLICY "Authenticated users can upload a banner."
    ON storage.objects
    FOR INSERT TO authenticated WITH CHECK (
        bucket_id = 'banners'
    );

CREATE POLICY "Allow owner to delete their own banner."
    ON storage.objects
    FOR DELETE TO authenticated USING (
        bucket_id = 'banners' AND (storage.foldername(name))[1] = (select auth.uid()::text)
    );

CREATE POLICY "Allow owner to update their own banner."
    ON storage.objects
    FOR UPDATE TO authenticated USING (
        bucket_id = 'banners' AND (storage.foldername(name))[1] = (select auth.uid()::text)
    );

CREATE POLICY "Allow everyone to see a banner."
    ON storage.objects
    FOR SELECT TO authenticated USING (
        bucket_id = 'banners'
    );