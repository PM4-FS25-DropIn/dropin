-- ===========================================
-- Migration:     Limit avatar file type, size, type and amount
--
-- Description:
--   - Limits the file size of avatar images to 5MB
--   - Only allows png, jpeg, webp, gifs and apng for avatar images
--   - Only allows up to 10 avatar images per user
-- ============================================
CREATE POLICY "Limit avatar file size to 5MB"
    ON storage.objects
    FOR INSERT TO authenticated WITH CHECK (
        bucket_id = 'avatars'
        AND (metadata->>'size')::int <= 5 * 1024 * 1024
    );

CREATE POLICY "Only allow png, jpeg, webp, gifs and apng for avatar images"
    ON storage.objects
    FOR INSERT TO authenticated WITH CHECK (
        bucket_id = 'avatars'
        AND (metadata->>'mime_type') IN (
            'image/png', 
            'image/jpeg', 
            'image/webp', 
            'image/gif',
            'image/apng'
        )
    );

CREATE POLICY "Only allow up to 10 avatar images per user"
    ON storage.objects
    FOR INSERT TO authenticated WITH CHECK (
        bucket_id = 'avatars'
        AND (
            SELECT count(*) FROM storage.objects 
            WHERE bucket_id = 'avatars' 
            AND owner = (SELECT auth.uid())
        ) < 10
    );