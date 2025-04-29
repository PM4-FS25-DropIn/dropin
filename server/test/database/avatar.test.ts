import { test } from 'node:test';
import assert from 'node:assert';
import { createClientHelper, createUser, generateRandomString } from './dbhelpers.js';

test('Users can upload avatars into their directory', async (t) => {
  const client = createClientHelper();
  
  const { user, password } = await createUser(client);

  if (user.email == null) {
    throw new Error('No email returned from user creation');
  }

  assert.ifError((await client.auth.signInWithPassword({
    email: user.email!,
    password: password,
  })).error);

  const uploadResult = await client.storage.from('avatars')
    .upload(user.id + '/avatar1.png', Buffer.from('test'), {
      contentType: 'image/png'
  });

  assert.ifError(uploadResult.error);
  console.log("Upload result:", uploadResult.data);
});

test('Authenticated users can upload an avatar', async (t) => {
  const client = createClientHelper();
  
  const { user, password } = await createUser(client);

  if (user.email == null) {
    throw new Error('No email returned from user creation');
  }

  assert.ifError((await client.auth.signInWithPassword({
    email: user.email!,
    password: password,
  })).error);

  const uploadResult = await client.storage.from('avatars')
    .upload(generateRandomString() + '/avatar1.png', Buffer.from('test'), {
      contentType: 'image/png'
  });

  assert.equal(uploadResult.data, null, "Expected data to be null, but got: " + uploadResult.data);
  assert.notEqual(uploadResult.error, null);
  console.log("Upload successfuly failed with: " + uploadResult.error!.message);
});

test('Uploaded avatar needs to be in user directory', async (t) => {
  const client = createClientHelper();
  
  const { user, password } = await createUser(client);

  if (user.email == null) {
    throw new Error('No email returned from user creation');
  }

  assert.ifError((await client.auth.signInWithPassword({
    email: user.email!,
    password: password,
  })).error);

  const uploadResult = await client.storage.from('avatars')
    .upload(generateRandomString() + '/avatar1.png', Buffer.from('test'), {
      contentType: 'image/dasdasdasd'
  });

  assert.equal(uploadResult.data, null, "Expected data to be null, but got: " + uploadResult.data);
  assert.notEqual(uploadResult.error, null);
  console.log("Upload successfuly failed with: " + uploadResult.error!.message);
});

test('Limit avatar upload to 5MB', async (t) => {
  assert.fail("Not implemented yet");
});

test('Only allow up to 10 avatar images per user', async (t) => {
  assert.fail("Not implemented yet");
});