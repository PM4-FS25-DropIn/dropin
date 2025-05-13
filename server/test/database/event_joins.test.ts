import { test } from 'node:test';
import assert from 'node:assert';
import { generateRandomString, setupRandomClientAndLogin } from './dbhelpers.js';
import { SupabaseClient } from '@supabase/supabase-js';

test('An authenticated user can join an event', async (t) => {
    const { client: creatingClient, user: creatingUser } = await setupRandomClientAndLogin();
    const { client: joiningClient, user: joiningUser } = await setupRandomClientAndLogin();

    const testEvent = await createEvent(creatingClient);

    assert.notEqual(testEvent, null, "Expected testEvent to be not null, but got null.");

    const { data: joinData, error: joinError } = await joiningClient.from('event_joins')
        .insert({
            event_id: testEvent.id,
            user_id: joiningUser.id
        })
        .select();

    assert.equal(joinError, null, "Expected event join to succeed, but it failed: " + joinError?.message);
    assert.notEqual(joinData, null, "Expected data not to be null, but got null.");
    
    const response = <unknown>joinData as any[];
    assert.equal(response.length, 1, "Expected one event join to be created, but got: " + response.length);
    assert.equal(response[0].event_id, testEvent.id, "Expected event_id to be " + testEvent.id + ", but got: " + response[0].event_id);
    assert.equal(response[0].user_id, joiningUser.id, "Expected user_id to be " + joiningUser.id + ", but got: " + response[0].user_id);

    const { data: selectData, error: selectError } = await creatingClient.from('event_joins')
        .select();

    assert.equal(selectError, null, "Expected event join selection to succeed, but it failed: " + selectError?.message + " for event_id: " + testEvent.id);
    assert.notEqual(selectData, null, "Expected data not to be null, but got null.");
    const selectResponse = <unknown>selectData as any[];
    assert.equal(selectResponse.length, 2, "Expected two event joins to be selected, but got: " + selectResponse.length  + " for event_id: " + testEvent.id);
    
    const containedUsers = selectResponse.map(e => e.user_id);
    const areCreaterAndJoinerContained = [ creatingUser.id, joiningUser.id ]
        .map(userId => containedUsers.includes(userId))
        .reduce((acc, curr) => acc && curr, true);
    
    assert.equal(areCreaterAndJoinerContained, true, "Expected both creating and joining users to be contained in the event joins, but they are not.");
});

test('An authenticated user can leave an event', async (t) => {
    const { client: creatingClient } = await setupRandomClientAndLogin();
    const { client: leavingClient, user: leavingUser } = await setupRandomClientAndLogin();

    const testEvent = await createEvent(creatingClient);

    assert.notEqual(testEvent, null, "Expected testEvent to be not null, but got null.");

    const { data: joinData, error: joinError } = await leavingClient.from('event_joins')
        .insert({
            event_id: testEvent.id,
            user_id: leavingUser.id
        }).select();

    assert.equal(joinError, null, "Expected event join to succeed, but it failed: " + joinError?.message);
    assert.notEqual(joinData, null, "Expected join data not to be null, but got null.");
    
    const joinResponse = <unknown>joinData as any[];
    assert.equal(joinResponse.length, 1, "Expected one event join to be created, but got: " + joinResponse.length);
    assert.equal(joinResponse[0].event_id, testEvent.id, "Expected event_id to be " + testEvent.id + ", but got: " + joinResponse[0].event_id);
    assert.equal(joinResponse[0].user_id, leavingUser.id, "Expected user_id to be " + leavingUser.id + ", but got: " + joinResponse[0].user_id);

    const { data: leaveData, error: leaveError } = await leavingClient.from('event_joins')
        .delete()
        .eq('event_id', testEvent.id)
        .eq('user_id', leavingUser.id)
        .select();

    assert.equal(leaveError, null, "Expected event leave to succeed, but it failed: " + leaveError?.message);
    assert.notEqual(leaveData, null, "Expected leave data not to be null, but got null.");

    const leaveResponse = <unknown>leaveData as any[];
    assert.equal(leaveResponse.length, 1, "Expected one event leave to be returned, but got: " + joinResponse.length);
    assert.equal(leaveResponse[0].event_id, testEvent.id, "Expected event_id to be " + testEvent.id + ", but got: " + joinResponse[0].event_id);
    assert.equal(leaveResponse[0].user_id, leavingUser.id, "Expected user_id to be " + leavingUser.id + ", but got: " + joinResponse[0].user_id);
});

test('An already banned user cannot join an event', async (t) => {
});

async function createEvent(client: SupabaseClient<any, any, any>): Promise<any> {
    const event_to_create = {
        title: generateRandomString(),
        description: generateRandomString(),
        start: new Date().toISOString(),
        end: new Date(Date.now() + 3600000).toISOString(),
        latitude: 50,
        longitude: 50,
        slot_limit: 10,
        slots_taken: 0,
        age_restricted: false,
        chat_enabled: true
    };

    const { data, error } = await client.from('events')
        .insert(event_to_create)
        .select();

    if (error) {
        assert.ifError(error);
    }

    return (<any>data)[0];
}