-- ===========================================
-- Migration:     Limit avatar file type, size, type and amount
--
-- Description:
--   - Limits the file size of avatar images to 5MB
--   - Only allows png, jpeg, webp, gifs and apng for avatar images
--   - Only allows up to 10 avatar images per user
-- ============================================

DROP POLICY IF EXISTS "Authenticated users can upload an avatar" on storage.objects;

CREATE OR REPLACE FUNCTION public.count_user_uploads_in(bucket text)
RETURNS INTEGER AS $$
BEGIN
  RETURN (
    SELECT COUNT(*) FROM storage.objects
    WHERE (bucket_id = bucket)
      AND (owner = auth.uid())
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Limit amout of avatar images to 10 per user

CREATE POLICY "Only allow up to 10 avatar images per user"
    ON storage.objects AS RESTRICTIVE
    FOR INSERT TO authenticated WITH CHECK (
        (bucket_id = 'avatars')
        AND (count_user_uploads_in('avatars') <= 10)
    );