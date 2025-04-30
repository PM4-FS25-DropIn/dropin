import { test } from 'node:test';
import assert from 'node:assert';
import { createClientHelper, createUser, generateRandomString } from './dbhelpers.js';
import { SupabaseClient, User } from '@supabase/supabase-js';

test('Users can upload avatars into their directory', async (t) => {
  const { client, user } = await setupRandomClientAndLogin();

  const uploadResult = await client.storage.from('avatars')
    .upload(user.identities![0]!.id + '/avatar1.png', generateRandomBlob(1024));

  assert.ifError(uploadResult.error);
  console.log("Upload result:", uploadResult.data);
});

test('Uploaded avatar needs to be in user directory', async (t) => {
  const { client } = await setupRandomClientAndLogin();

  const uploadResult = await client.storage.from('avatars')
    .upload(generateRandomString() + '/avatar1.png', generateRandomBlob(1024));

  assert.equal(uploadResult.data, null, "Expected data to be null, but got: " + uploadResult.data);
  assert.notEqual(uploadResult.error, null);
  console.log("Upload successfuly failed with: " + uploadResult.error!.message);
});

test('Limit avatar upload to 5MB', async (t) => {
  const { client, user } = await setupRandomClientAndLogin();
  
    const uploadResult = await client.storage.from('avatars')
      .upload(user.identities![0]!.id + '/avatar1.png', generateRandomBlob(6 * 1024 * 1024));
  
    assert.equal(uploadResult.data, null, "Expected data to be null, but got: " + uploadResult.data);
    assert.notEqual(uploadResult.error, null);
    assert.equal((<any>uploadResult.error).statusCode, 413, "Expected status code to be 413, but got: " + (<any>uploadResult.error).statusCode!);
    console.log("Upload successfuly failed with: " + uploadResult.error!.message);

});

test('Only allow up to 10 avatar images per user', async (t) => {
  const { client, user } = await setupRandomClientAndLogin();

  let lastResult = null;
  for (let i = 0; i < 11; i++) {
    lastResult = await client.storage.from('avatars')
      .upload(user.identities![0]!.id + '/avatar' + i + '.png', generateRandomBlob(1024));
  }

  assert.notEqual(lastResult, null, "Expected lastResult to be not null, but got: " + lastResult);
  assert.equal(lastResult!.error, null, "Expected upload to fail, but got: " + lastResult!.error?.message);
});

test('Disallow non-image files', async (t) => {
  const { client, user } = await setupRandomClientAndLogin();
  
    const uploadResult = await client.storage.from('avatars')
      .upload(user.identities![0]!.id + '/avatar1.txt', generateRandomBlob(1024, 'text/plain'));
  
    assert.equal(uploadResult.data, null, "Expected data to be null, but got: " + uploadResult.data);
    assert.notEqual(uploadResult.error, null);
});

async function setupRandomClientAndLogin(): Promise<{client: SupabaseClient<any, any, any>, user: User}> {
  const client = createClientHelper();
  
  const { user, password } = await createUser(client);

  if (user.email == null) {
    throw new Error('No email returned from user creation');
  }

  assert.ifError((await client.auth.signInWithPassword({
    email: user.email!,
    password: password,
  })).error);

  return {client, user};
}

function generateRandomBlob(size: number, type: string = 'image/png'): Blob {
    return new Blob([new ArrayBuffer(size)], { type });
};