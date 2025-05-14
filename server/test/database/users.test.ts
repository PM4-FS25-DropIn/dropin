import { test } from 'node:test';
import assert from 'node:assert';
import { createEvent, createSuperClient, setupRandomClientAndLogin } from './dbhelpers.js';

test('Delete all user data on user deletion', async (t) => {
    const superClient = await createSuperClient();
    const { client: clientToDelete, user: userToDelete } = await setupRandomClientAndLogin();
    const { client: clientToKeep, user: userToKeep } = await setupRandomClientAndLogin();
    
    const eventToDelete = await createEvent(clientToDelete);
    const eventToKeep = await createEvent(clientToKeep);
    
    assert.notEqual(eventToDelete, null, "Expected eventToDelete to be not null, but got: " + eventToDelete);
    assert.notEqual(eventToKeep, null, "Expected eventToJoin to be not null, but got: " + eventToKeep);
        
    const { error: eventToDeleteJoinError } = await clientToKeep.from('event_joins')
        .insert({
            event_id: eventToDelete.id,
            user_id: userToKeep.id,
        });
    assert.equal(eventToDeleteJoinError, null, "Expected event join to succeed, but it failed: " + eventToDeleteJoinError?.message)

    const { error: eventToKeepJoinError } = await clientToDelete.from('event_joins')
        .insert({
            event_id: eventToKeep.id,
            user_id: userToDelete.id,
        });
    assert.equal(eventToKeepJoinError, null, "Expected event join to succeed, but it failed: " + eventToKeepJoinError?.message);

    const { error: messageAddError } = await clientToDelete.from('messages')
        .insert({
            chat_room_id: eventToDelete.id,
            sender_id: userToDelete.id,
            content: "Message to delete",
            created_at: new Date().toISOString()
        });
    assert.equal(messageAddError, null, "Expected message add to succeed, but it failed: " + messageAddError?.message);
    
    // delete and assert successful deletion

    const { data: deleteUserData, error: deleteUserError } = await superClient.auth.admin.deleteUser(userToDelete.id);
    assert.equal(deleteUserError, null, "Expected user deletion to succeed, but it failed: " + deleteUserError?.message);
    assert.notEqual(deleteUserData, null, "Expected deleteData to be not null, but got: " + deleteUserData);

    assert.equal((<any>deleteUserData).user.id, null, "Expected deleted_at to be null, but got: " + userToDelete.id);

    // assert that the events owned by the user is deleted
    const { data: deleteEventData, error: deleteEventError } = await superClient.from('events')
        .select()
        .eq('id', eventToDelete.id);
    assert.equal(deleteEventError, null, "Expected event deletion to succeed, but it failed: " + deleteEventError?.message);
    assert.equal(deleteEventData?.length, 0, "Expected deleteEventData to be null, but got: " + JSON.stringify(deleteEventData));

    // assert that the event join is deleted
    const { data: deleteJoinsData, error: deleteJoinsError } = await superClient.from('event_joins')
        .select()
        .eq('event_id', eventToDelete.id);
    assert.equal(deleteJoinsError, null, "Expected deleteJoinsError to be null, but got: " + deleteJoinsError);
    assert.equal(deleteJoinsData?.length, 0, "Expected deleteJoinsData length to be 0, but got: " + deleteJoinsData); 

    // assert that the messages are deleted
    const { data: deleteMessagesData, error: deleteMessagesError } = await superClient.from('messages')
        .select()
        .eq('chat_room_id', eventToDelete.id);
    assert.equal(deleteMessagesError, null, "Expected deleteMessagesError to be null, but got: " + deleteMessagesError);
    assert.equal(deleteMessagesData?.length, 0, "Expected deleteMessagesData length to be 0, but got: " + deleteMessagesData);
});