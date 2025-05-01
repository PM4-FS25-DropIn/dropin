create policy "Avatar images are publicly accessible." on storage.objects
    for select
    to authenticated
    using
    (bucket_id = 'avatars');

create policy "Authenticated users can upload an avatar" on storage.objects
    for insert
    to authenticated
    with check (
    bucket_id = 'avatars'
    and
    (storage.foldername(name))[1] = (select auth.uid()::text)
    );
