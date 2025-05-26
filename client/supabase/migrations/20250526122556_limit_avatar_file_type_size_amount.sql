CREATE POLICY "Authenticated users can upload an avatar"
    ON storage.objects
    FOR INSERT TO authenticated WITH CHECK (
        (bucket_id = 'avatars'::text) AND (( SELECT (auth.uid())::text AS uid) = (storage.foldername(name))[1])
    );

CREATE POLICY "Allow owner files to delete their own avatars"
    ON storage.objects
    FOR DELETE TO authenticated USING (
        (bucket_id = 'avatars'::text) 
        AND (( SELECT (auth.uid())::text AS uid) = (storage.foldername(name))[1])
    );

CREATE POLICY "Allow owner files to update their own avatars"
    ON storage.objects
    FOR DELETE TO authenticated USING (
        (bucket_id = 'avatars'::text) 
        AND (( SELECT (auth.uid())::text AS uid) = (storage.foldername(name))[1])
    );


-- Limit file size to 5MB and limit mime types to images only
UPDATE storage.buckets SET file_size_limit = 5242880, allowed_mime_types = ARRAY['image/*'] WHERE id = 'avatars';