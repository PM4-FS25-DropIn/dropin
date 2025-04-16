-- ===========================================
-- Migration:     update_profile_info
--
-- Description:
--   - Adds bio and city columns to the profiles table.
-- ===========================================

alter table public.profiles add column bio text not null default '';
alter table public.profiles add column city text;