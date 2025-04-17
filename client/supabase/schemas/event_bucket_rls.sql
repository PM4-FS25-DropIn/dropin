/*
CREATE POLICY "Event bucket is publicly accessible." ON storage.objects
    FOR SELECT
    TO authenticated
    USING
    (bucket_id = 'events');

CREATE POLICY "Authenticated users can upload an avatar" ON storage.objects
    FOR INSERT
    TO authenticated
    WITH CHECK (
    bucket_id = 'events'
    and
    (storage.foldername(name))[1] = (select auth.uid()::text)
    );
    */