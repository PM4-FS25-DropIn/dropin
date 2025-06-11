-- ===========================================
-- Migration:     apply_new_fields_on_new_user
--
-- Description:
--   - Alters handle_new_user function to include new fields in the profiles table (emojicode and city).
-- ===========================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.profiles (id, username, emojicode, city)
  VALUES (new.id, new.raw_user_meta_data->>'username', new.raw_user_meta_data->>'emojicode', new.raw_user_meta_data->>'city');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY definer;
