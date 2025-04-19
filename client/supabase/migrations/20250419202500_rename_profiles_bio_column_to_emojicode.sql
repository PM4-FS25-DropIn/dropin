-- ===========================================
-- Migration:     rename_profiles_bio_column_to_emojicode
--
-- Description:
--   - Renames the profiles.bio column to profiles.emojicode.
--   - Adds a constraint to ensure that the emojicode column has a maximum length of 5 characters.
-- ===========================================

alter table public.profiles rename column bio to emojicode;
alter table public.profiles ADD CONSTRAINT profiles_emojicode_max_length CHECK (char_length(emojicode) = 5);