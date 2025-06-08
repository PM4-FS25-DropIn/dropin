-- ===========================================
-- Migration:     change_emojicode_constraint
--
-- Description:
--   - Updates the emojicode column constraint to ensure that it is not empty and has a maximum length of 40 characters.

-- ===========================================

ALTER TABLE public.profiles ALTER column emojicode TYPE VARCHAR(40) COLLATE pg_catalog."default" USING emojicode::VARCHAR(40);
ALTER TABLE public.profiles ADD CONSTRAINT profiles_emojicode_check CHECK (emojicode <> '');
