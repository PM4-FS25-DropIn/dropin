import { test } from 'node:test';
import assert from 'node:assert';
import { createClientHelper, createUser, generateRandomString } from './dbhelpers.js';
import { SupabaseClient, User } from '@supabase/supabase-js';

/**
 * Tests if an authenticated user can upload an avatar into their directory.
 */
test('Users can upload avatars into their directory', async (t) => {
  const { client, user } = await setupRandomClientAndLogin();

  const uploadResult = await client.storage.from('avatars')
    .upload(user.identities![0]!.id + '/avatar1.png', generateRandomBlob(1024));

  assert.equal(uploadResult.error, null, "Expected upload to succeed, but it failed: " + uploadResult.error?.message);
  assert.notEqual(uploadResult.data, null, "Expected data not to be null, but got null.");
});

/**
 * A user should not be able to upload an avatar into another user's directory.
 */
test('Uploaded avatar needs to be in user directory', async (t) => {
  const { client } = await setupRandomClientAndLogin();

  const uploadResult = await client.storage.from('avatars')
    .upload(generateRandomString() + '/avatar1.png', generateRandomBlob(1024));

  assert.equal(uploadResult.data, null, "Expected data to be null, but got: " + uploadResult.data);
  assert.notEqual(uploadResult.error, null);
});

/**
 * An user should not be able to upload an avatar into the root directory.
 */
test('Limit avatar upload to 5MB', async (t) => {
  const { client, user } = await setupRandomClientAndLogin();
  
    const uploadResult = await client.storage.from('avatars')
      .upload(user.identities![0]!.id + '/avatar1.png', generateRandomBlob(6 * 1024 * 1024));
  
    assert.equal(uploadResult.data, null, "Expected data to be null, but got: " + uploadResult.data);
    assert.notEqual(uploadResult.error, null);
    assert.equal((<any>uploadResult.error).statusCode, 413, "Expected status code to be 413, but got: " + (<any>uploadResult.error).statusCode!);
    console.log("Upload successfuly failed with: " + uploadResult.error!.message);

});

/**
 * A user should not be able to upload more than 10 avatars.
 */
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

/**
 * A user should not be able to upload an avatar with a non-image file type.
 */
test('Disallow non-image files', async (t) => {
  const { client, user } = await setupRandomClientAndLogin();
  
    const uploadResult = await client.storage.from('avatars')
      .upload(user.identities![0]!.id + '/avatar1.txt', generateRandomBlob(1024, 'text/plain'));
  
    assert.equal(uploadResult.data, null, "Expected data to be null, but got: " + uploadResult.data);
    assert.notEqual(uploadResult.error, null);
});

/**
 * A user should be able to delete their own avatar.
 */
test('User can delete their own avatar', async (t) => {
  const { client, user } = await setupRandomClientAndLogin();

  const targetFile = user.identities![0]!.id + '/avatar1.png';
  const uploadResult = await client.storage.from('avatars')
      .upload(targetFile, generateRandomBlob(1024));

  assert.equal(uploadResult.error, null, "Expected the upload to succeed, but it failed: " + uploadResult.error?.message);

  const deleteResult = await client.storage.from('avatars')
      .remove([targetFile]);

  assert.equal(deleteResult.error, null, "Expected delete action to succed, but it failed " + deleteResult.error?.message);
});

/**
 * A user should not be able to delete another user's avatar.
 */
test('Disallow deleting other users avatars', async (t) => {
  const { client: clientA, user: userA } = await setupRandomClientAndLogin();
  
  const targetFile = userA.identities![0]!.id + '/avatar1.png';
  const uploadResult = await clientA.storage.from('avatars')
    .upload(targetFile, generateRandomBlob(1024));

  assert.equal(uploadResult.error, null, "Expected upload to succeed, but it failed: " + uploadResult.error?.message);
  
  const { client: clientB } = await setupRandomClientAndLogin();

  const deleteResult = await clientB.storage.from('avatars')
    .remove([targetFile]);
  
  assert.notEqual(deleteResult.data, null, "Expected data not to be null, but got null.");
  // data.length should be 0, because the file was not deleted
  assert.equal(deleteResult.data?.length, 0, "Expected data length to be 0, but got: " + deleteResult.data?.length);
});

/**
 * A authenticated user should be able to get another user's avatar.
 */
test('Authenticated user can get other users avatars', async (t) => {
  const { client: clientA, user: userA } = await setupRandomClientAndLogin();
  
  const targetFile = userA.identities![0]!.id + '/avatar1.png';
  const uploadResult = await clientA.storage.from('avatars')
    .upload(targetFile, generateRandomBlob(1024));

  assert.equal(uploadResult.error, null, "Expected upload to succeed, but it failed: " + uploadResult.error?.message);
  
  const { client: clientB } = await setupRandomClientAndLogin();

  const downloadResult = await clientB.storage.from('avatars')
    .download(targetFile);
  
  assert.equal(downloadResult.error, null, "Expected download action to succeed, but it failed: " + downloadResult.error?.message);
  assert.notEqual(downloadResult.data, null, "Expected data not to be null, but got null.");
  assert.equal(downloadResult.data?.size, 1024, "Expected data size to be 1024, but got: " + downloadResult.data?.size);
});

/**
 * An unauthenticated user should not be able to get another user's avatar.
 */
test('An unaithenticated user should not be able to get another users avatar', async (t) => {
  const { client: uploadClient, user: uploadUser } = await setupRandomClientAndLogin();

  const targetFile = uploadUser.identities![0]!.id + '/avatar1.png';
  const uploadResult = await uploadClient.storage.from('avatars')
    .upload(targetFile, generateRandomBlob(1024));

  assert.equal(uploadResult.error, null, "Expected upload to succeed, but it failed: " + uploadResult.error?.message);

  const client = createClientHelper();
  
  const downloadResult = await client.storage.from('avatars')
    .download(targetFile);

  assert.notEqual(downloadResult.error, null, "Expected download action to fail, but it succeeded: " + downloadResult.error?.message);
});


/**
 * Creates a new client and creates a new user using random credentials.
 * @return {client: SupabaseClient, user: User} The client and the user created.
 */
async function setupRandomClientAndLogin(): Promise<{client: SupabaseClient<any, any, any>, user: User}> {
  const client = createClientHelper();
  
  const { user, password } = await createUser(client);

  if (user.email == null) {
    throw new Error('No email returned from user creation');
  }

  const signInResult = await client.auth.signInWithPassword({
    email: user.email!,
    password: password,
  });

  assert.equal(signInResult.error, null, "Expected sign in to succeed, but it failed: " + signInResult.error?.message);

  return {client, user};
}

/**
 * Creates a random blob of the given size and type.
 * @param size The size of the blob in bytes.
 * @param type The type of the blob. Default is 'image/png'.
 * @returns {Blob} The created blob.
 */
function generateRandomBlob(size: number, type: string = 'image/png'): Blob {
    return new Blob([new ArrayBuffer(size)], { type });
};