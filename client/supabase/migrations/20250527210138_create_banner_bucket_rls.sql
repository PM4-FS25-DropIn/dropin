-- ===========================================
-- Migration:     Create Banner Bucket
--
-- Description:
--   - Creates row-level security (RLS) policies for the 'banner' bucket
--   - Allows authenticated users to publicly read banner images
--   - Allows authenticated users to upload banner to their own folder
-- ============================================

create policy "Users can upload a banner." on storage.objects
for insert to authenticated with check (
    bucket_id = 'banners'
);

create policy "Users can update the banner." on storage.objects
for update to authenticated using (
    bucket_id = 'banners'
);

create policy "Users can select the banner." on storage.objects
for select to authenticated using (
    bucket_id = 'banners'
);