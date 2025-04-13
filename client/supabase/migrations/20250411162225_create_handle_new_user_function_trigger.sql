-- ===========================================
-- Migration:     create_handle_new_user_function_trigger
--
-- Description:
--   - Creates a trigger function that inserts a new row into the 'profiles' table
--     when a new user is created in 'auth.users'
--   - Extracts the username from `raw_user_meta_data`
--   - Trigger runs after insert on 'auth.users'
-- ===========================================
create function public.handle_new_user()
returns trigger
set search_path = ''
as $$
begin
  insert into public.profiles (id, username)
  values (new.id, new.raw_user_meta_data->>'username');
  return new;
end;
$$ language plpgsql security definer;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
