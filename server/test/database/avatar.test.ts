import { test } from 'node:test';
import assert from 'node:assert';
import { generateRandomBlob, generateRandomString, setupRandomClientAndLogin } from './dbhelpers.js';

const AVATAR_BUCKET = 'avatars';
const AVATAR_FILE_NAME = '/avatar.png';

/**
 * Tests if an authenticated user can upload an avatar into their directory.
 */
test('Users can upload avatars into their directory', async (t) => {
  const { client, user } = await setupRandomClientAndLogin();

  const uploadResult = await client.storage.from(AVATAR_BUCKET)
    .upload(user.identities![0]!.id + AVATAR_FILE_NAME, generateRandomBlob(1024));

  assert.equal(uploadResult.error, null, "Expected upload to succeed, but it failed: " + uploadResult.error?.message);
  assert.notEqual(uploadResult.data, null, "Expected data not to be null, but got null.");
});

/**
 * A user should not be able to upload an avatar into another user's directory.
 */
test('Uploaded avatar needs to be in user directory', async (t) => {
  const { client } = await setupRandomClientAndLogin();

  const uploadResult = await client.storage.from(AVATAR_BUCKET)
    .upload(generateRandomString() + AVATAR_FILE_NAME, generateRandomBlob(1024));

  assert.equal(uploadResult.data, null, "Expected data to be null, but got: " + uploadResult.data);
  assert.notEqual(uploadResult.error, null);
});

/**
 * An user should not be able to upload an avatar into the root directory.
 */
test('Limit avatar upload to 10MB', async (t) => {
  const { client, user } = await setupRandomClientAndLogin();
  
    const uploadResult = await client.storage.from(AVATAR_BUCKET)
      .upload(user.identities![0]!.id + AVATAR_FILE_NAME, generateRandomBlob(11 * 1024 * 1024));
  
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
    lastResult = await client.storage.from(AVATAR_BUCKET)
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
  
    const uploadResult = await client.storage.from(AVATAR_BUCKET)
      .upload(user.identities![0]!.id + '/avatar1.txt', generateRandomBlob(1024, 'text/plain'));
  
    assert.equal(uploadResult.data, null, "Expected data to be null, but got: " + uploadResult.data);
    assert.notEqual(uploadResult.error, null);
});

/**
 * A user should be able to delete their own avatar.
 */
test('User can delete their own avatar', async (t) => {
  const { client, user } = await setupRandomClientAndLogin();

  const targetFile = user.identities![0]!.id + AVATAR_FILE_NAME;
  const uploadResult = await client.storage.from(AVATAR_BUCKET)
      .upload(targetFile, generateRandomBlob(1024));

  assert.equal(uploadResult.error, null, "Expected the upload to succeed, but it failed: " + uploadResult.error?.message);

  const deleteResult = await client.storage.from(AVATAR_BUCKET)
      .remove([targetFile]);

  assert.equal(deleteResult.error, null, "Expected delete action to succed, but it failed " + deleteResult.error?.message);
});

/**
 * A user should not be able to delete another user's avatar.
 */
test('Disallow deleting other users avatars', async (t) => {
  const { client: clientA, user: userA } = await setupRandomClientAndLogin();
  
  const targetFile = userA.identities![0]!.id + AVATAR_FILE_NAME;
  const uploadResult = await clientA.storage.from(AVATAR_BUCKET)
    .upload(targetFile, generateRandomBlob(1024));

  assert.equal(uploadResult.error, null, "Expected upload to succeed, but it failed: " + uploadResult.error?.message);
  
  const { client: clientB } = await setupRandomClientAndLogin();

  const deleteResult = await clientB.storage.from(AVATAR_BUCKET)
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
  
  const targetFile = userA.identities![0]!.id + AVATAR_FILE_NAME;
  const uploadResult = await clientA.storage.from(AVATAR_BUCKET)
    .upload(targetFile, generateRandomBlob(1024));

  assert.equal(uploadResult.error, null, "Expected upload to succeed, but it failed: " + uploadResult.error?.message);
  
  const { client: clientB } = await setupRandomClientAndLogin();

  const downloadResult = await clientB.storage.from(AVATAR_BUCKET)
    .download(targetFile);
  
  assert.equal(downloadResult.error, null, "Expected download action to succeed, but it failed: " + downloadResult.error?.message);
  assert.notEqual(downloadResult.data, null, "Expected data not to be null, but got null.");
  assert.equal(downloadResult.data?.size, 1024, "Expected data size to be 1024, but got: " + downloadResult.data?.size);
});
