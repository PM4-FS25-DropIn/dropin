CREATE POLICY "Allow owner files to delete their own avatars"
    ON storage.objects
    FOR DELETE TO authenticated USING (
        owner = (SELECT auth.uid())
    );