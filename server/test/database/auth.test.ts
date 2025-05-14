import { test } from 'node:test';
import assert from 'node:assert';
import { createClientHelper, createUser, setupRandomClientAndLogin} from './dbhelpers.js';
import type { SupabaseClient } from '@supabase/supabase-js';

/**
 * Tests that the handle_new_user trigger
 * creates a profiles row with the new user's ID
 * and copies through the `username` from user_metadata.
 */
test('handle_new_user trigger populates profiles table', async (t) => {
  const client: SupabaseClient = createClientHelper();
  const { user } = await createUser(client);

  const { data: profile, error } = await client
    .from('profiles')
    .select('id, username')
    .eq('id', user.id)
    .single();
 
  assert.equal(error, null, `Unexpected error querying profiles: ${error?.message}`);
  assert(profile, 'Expected a profile row to exist, but got none');
  assert.equal(
    profile.id,
    user.id,
    `Profile.id should be ${user.id}, but was ${profile.id}`
  );
  assert.equal(
    profile.username,
    (user as any).user_metadata.username,
    `Profile.username should be ${(user as any).user_metadata.username}, but was ${profile.username}`
  );
});

test('handle_new_user trigger populates profiles with id & username', async () => {
  const { client, user} = await setupRandomClientAndLogin();
  assert(user.id, 'Expected user.id to be set');
  const initialUsername = (user as any).user_metadata?.username as string | null;

  const profile = await fetchProfile(client, user.id);
  assert.strictEqual(profile.id, user.id,      'profile.id should match user.id');
  assert.strictEqual(
    profile.username,
    initialUsername,
    'profile.username should come from raw_user_meta_data->>username'
  );
});


test('handle_new_user trigger does not duplicate profile on user update', async () => {
  const { client, user } = await setupRandomClientAndLogin();
  assert(user.id);
  const originalUsername = (user as any).user_metadata?.username as string | null;

  const newUsername = originalUsername ? originalUsername + '_x' : 'x';
  const { error: updErr } = await client.auth.admin.updateUserById(user.id, {
    user_metadata: { username: newUsername }
  });
  assert.equal(updErr, null, `Update error: ${updErr?.message}`);

  const profile = await fetchProfile(client, user.id);
  assert.strictEqual(profile.username, originalUsername);
});

async function fetchProfile(admin: SupabaseClient, userId: string) {
  const { data, error } = await admin
    .from('profiles')
    .select('id, username')
    .eq('id', userId)
    .single();
  if (error) throw new Error(`Error fetching profile: ${error.message}`);
  return data as { id: string; username: string | null };
}
