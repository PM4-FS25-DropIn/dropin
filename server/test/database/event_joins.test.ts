import { test } from 'node:test';
import assert from 'node:assert';
import { createSuperClient, generateRandomString, setupRandomClientAndLogin } from './dbhelpers.js';
import { SupabaseClient } from '@supabase/supabase-js';

test('An authenticated user can join an event', async (t) => {
    const serviceClient = createSuperClient();
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

    const { data: selectData, error: selectError } = await serviceClient.from('event_joins')
        .select()
        .eq('event_id', testEvent.id);

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

test('The creating user is automatically joint to the event', async (t) => {
    const { client: creatingClient, user: creatingUser } = await setupRandomClientAndLogin();

    const testEvent = await createEvent(creatingClient);
    assert.notEqual(testEvent, null, "Expected testEvent to be not null, but got null.");

    const { data: selectData, error: selectError } = await creatingClient.from('event_joins')
        .select()
        .eq('event_id', testEvent.id)
        .eq('user_id', creatingUser.id);

    assert.equal(selectError, null, "Expected event join selection to succeed, but it failed: " + selectError?.message + " for event_id: " + testEvent.id);
    assert.notEqual(selectData, null, "Expected data not to be null, but got null.");
    
    const selectResponse = <unknown>selectData as any[];
    assert.equal(selectResponse.length, 1, "Expected one event join to be selected, but got: " + selectResponse.length  + " for event_id: " + testEvent.id);
    assert.equal(selectResponse[0].event_id, testEvent.id, "Expected event_id to be " + testEvent.id + ", but got: " + selectResponse[0].event_id);
    assert.equal(selectResponse[0].user_id, creatingUser.id, "Expected user_id to be " + creatingUser.id + ", but got: " + selectResponse[0].user_id);
});

test('Joining an event increases the slot counter', async (t) => {
    const { client: creatingClient } = await setupRandomClientAndLogin();
    const { client: joiningClient, user: joiningUser } = await setupRandomClientAndLogin();

    const testEvent = await createEvent(creatingClient);
    assert.notEqual(testEvent, null, "Expected testEvent to be not null, but got null.");

    // Fetch and check initial slots_taken value. Should be 1 as the creator is added to the event automatically.
    const { data: slotsTakenDaten, error: slotsTakenError } = await creatingClient.from('events')
        .select('slots_taken')
        .eq('id', testEvent.id);
    
    const slotsTakenResponse = <unknown>slotsTakenDaten as any[];
    assert.equal(slotsTakenError, null, "Expected event slots_taken selection to succeed, but it failed: " + slotsTakenError?.message);
    assert.notEqual(slotsTakenResponse, null, "Expected data not to be null, but got null.");
    assert.equal(slotsTakenResponse[0].slots_taken, 1, "Expected one event to be selected, but got: " + slotsTakenResponse.length);

    // Join the event with another user
    const { error: joinError } = await joiningClient.from('event_joins')
        .insert({
            event_id: testEvent.id,
            user_id: joiningUser.id
        });
    assert.equal(joinError, null, "Expected event join to succeed, but it failed: " + joinError?.message);

    // Fetch and check initial slots_taken value. Should be 2 this time, as we have two users in the event.
    const { data: slotsTakenAfterJoinDaten, error: slotsTakenAfterJoinError } = await creatingClient.from('events')
        .select('slots_taken')
        .eq('id', testEvent.id);
    
    const slotsTakenAfterJoinResponse = <unknown>slotsTakenAfterJoinDaten as any[];
    assert.equal(slotsTakenAfterJoinError, null, "Expected event slots_taken selection to succeed, but it failed: " + slotsTakenAfterJoinError?.message);
    assert.notEqual(slotsTakenAfterJoinResponse, null, "Expected data not to be null, but got null.");
    assert.equal(slotsTakenAfterJoinResponse[0].slots_taken, 2, "Expected one event to be selected, but got: " + slotsTakenResponse.length);
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

test('Leaving an event decreases the slot counter', async (t) => {
    const { client: creatingClient, user: creatingUser } = await setupRandomClientAndLogin();

    const testEvent = await createEvent(creatingClient);
    assert.notEqual(testEvent, null, "Expected testEvent to be not null, but got null.");
    
    const { error: leaveError } = await creatingClient.from('event_joins')
        .delete()
        .eq('event_id', testEvent.id)
        .eq('user_id', creatingUser.id)
    assert.equal(leaveError, null, "Expected event leave to succeed, but it failed: " + leaveError?.message);

    // Fetch and check slots_taken value. Should be 0 as the creator is removed from the event.
    const { data: slotsTakenDaten, error: slotsTakenError } = await creatingClient.from('events')
        .select('slots_taken')
        .eq('id', testEvent.id);

    assert.equal(slotsTakenError, null, "Expected event slots_taken selection to succeed, but it failed: " + slotsTakenError?.message);
    assert.notEqual(slotsTakenDaten, null, "Expected data not to be null, but got null.");
    
    const slotsTakenResponse = <unknown>slotsTakenDaten as any[];
    assert.equal(slotsTakenResponse.length, 1, "Expected one event to be selected, but got: " + slotsTakenResponse.length);
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