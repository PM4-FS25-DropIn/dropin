-- ===========================================
-- Migration:     rename_profiles_bio_column_to_emojicode
--
-- Description:
--   - Renames the profiles.bio column to profiles.emojicode.
--   - Adds a constraint to ensure that the emojicode column has a maximum length of 40 characters.
--     The limit of 40 is semi-arbitrary, but should be sufficient for most emoji code combinations.
--     It's based on an estimate: 5 emojis × ~8 bytes = 40 bytes.
--     We use 8 bytes per emoji to account for grapheme clusters made up of multiple code points.
--     Fun fact: The longest emoji I found consisted of 14 code points.
-- ===========================================

alter table public.profiles rename column bio to emojicode;
alter table public.profiles ADD CONSTRAINT profiles_emojicode_max_length CHECK (char_length(emojicode) = 40);