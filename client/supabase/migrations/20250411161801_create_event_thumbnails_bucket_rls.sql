create policy "Users can upload event thumbnails." on storage.objects
for insert to authenticated with check (
    bucket_id = 'event-thumbnails'
);