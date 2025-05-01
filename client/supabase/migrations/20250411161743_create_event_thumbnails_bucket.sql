-- ===========================================
-- Migration:     create_event_bucket
--
-- Description:
--   - Creates a new storage bucket named 'events'
--   - Used for storing images or files related to events
-- ===========================================

insert into storage.buckets
(id, name, public)
values
('event-thumbnails', 'event-thumbnails', true);