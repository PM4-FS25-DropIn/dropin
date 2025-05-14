import { test } from 'node:test';
import assert from 'node:assert';
import { createSuperClient, generateRandomString, setupRandomClientAndLogin } from './dbhelpers.js';
import { SupabaseClient } from '@supabase/supabase-js';

test('An authenticated user can create events', async (t) => {
    const { client } = await setupRandomClientAndLogin();

    
    const event_to_create = {
        title: "this is a test event",
        description: "this is a cool description",
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

    let response = data as any;

    assert.equal(error, null, "Expected event creation to succeed, but it failed: " + error?.message);
    assert.notEqual(response, null, "Expected data not to be null, but got null.");
    assert.equal(response.length, 1, "Expected one event to be created, but got: " + response.length);
    assert.equal(response[0].title, event_to_create.title, "Expected title to be " + event_to_create.title + ", but got: " + response[0].title);
    assert.equal(response[0].description, event_to_create.description, "Expected description to be " + event_to_create.description + ", but got: " + response[0].description);
    assert.equal(response[0].latitude, event_to_create.latitude, "Expected latitude to be " + event_to_create.latitude + ", but got: " + response[0].latitude);
    assert.equal(response[0].longitude, event_to_create.longitude, "Expected longitude to be " + event_to_create.longitude + ", but got: " + response[0].longitude);
    assert.equal(response[0].slot_limit, event_to_create.slot_limit, "Expected slot_limit to be " + event_to_create.slot_limit + ", but got: " + response[0].slot_limit);
    assert.equal(response[0].slots_taken, event_to_create.slots_taken, "Expected slots_taken to be " + event_to_create.slots_taken + ", but got: " + response[0].slots_taken);
    assert.equal(response[0].age_restricted, event_to_create.age_restricted, "Expected age_restricted to be " + event_to_create.age_restricted + ", but got: " + response[0].age_restricted);
});

test('An authenticated user can update their own events', async (t) => {
    const { client } = await setupRandomClientAndLogin();
    const testEvent = await createEvent(client);

    testEvent.title = "this is a test event updated";

    const { data, error } = await client.from('events')
        .update(testEvent)
        .eq('id', testEvent.id)
        .select();

    assert.equal(error, null, "Expected event update to succeed, but it failed: " + error?.message);
    assert.notEqual(data, null, "Expected data not to be null, but got null.");
    
    const response = <unknown>data as any[];
    assert.equal(response.length, 1, "Expected one event to be updated, but got: " + response.length);
    assert.equal(response[0].title, testEvent.title, "Expected title to be " + testEvent.title + ", but got: " + response[0].title);
});

test('An authenticated user can delete their own events', async (t) => {
    const { client } = await setupRandomClientAndLogin();
    const testEvent = await createEvent(client);

    const { error: deleteError } = await client.from('events')
        .delete()
        .eq('id', testEvent.id);
    assert.equal(deleteError, null, "Expected event deletion to succeed, but it failed: " + deleteError?.message);

    const { data: fetchedData, error: fetchError } = await client.from('events').select('*').eq('id', testEvent.id);
    assert.equal(fetchError, null, "Expected event retrieval to succeed, but it failed: " + fetchError?.message);
    assert.equal((<[]>fetchedData).length, 0, "Expected no events to be returned, but got: " + (<[]>fetchedData).length);
});

test('An authenticated user cannot delete another user\'s events', async (t) => {
    const { client: clientA } = await setupRandomClientAndLogin();
    const { client: clientB } = await setupRandomClientAndLogin();

    const eventOwnedByA = await createEvent(clientA);
    const { error } = await clientB.from('events')
        .delete()
        .eq('id', eventOwnedByA.id);
    
    assert.equal(error, null, "Expected event deletion to fail, but it succeeded: " + error?.message);
});

test('An authenticated user can see all events', async (t) => {
    const { client: clientA } = await setupRandomClientAndLogin();
    const { client: clientB } = await setupRandomClientAndLogin();

    const testEventA = await createEvent(clientA);
    const testEventB = await createEvent(clientB);

    assert.notEqual(testEventA, null, "Expected testEventA to be not null, but got: " + testEventA);
    assert.notEqual(testEventB, null, "Expected testEventB to be not null, but got: " + testEventB);

    const { data, error } = await clientA.from('events').select();

    assert.equal(error, null, "Expected event retrieval to succeed, but it failed: " + error?.message);
    
    const response = data as any;
    assert.ok(response.length >= 2, "Expected at least two events to be returned, but got: " + response.length);

    const areAllPresent = [testEventA.id, testEventB.id]
        .map((event: any) => response.includes(event.id));
    assert.equal(
        areAllPresent.length == 2, 
        true, 
        "Expected same ids but some are missing or diffrent." + response.map((event: any) => event.id)
    );
});

test('fetch_events_feed returns a maximum of 5 events when more than 5 exist', async () => {
  const admin      = createSuperClient();
  const { client: userClient, user } = await setupRandomClientAndLogin();

  await seedEvents(admin, 7, user.id);

  const { data: feed, error } = await userClient
    .rpc('fetch_events_feed', { excluded_ids: [] });

  assert.equal(error, null, `RPC error: ${error?.message}`);
  assert(Array.isArray(feed), 'Expected feed to be an array');
  assert(
    (feed as any[]).length <= 5,
    `Expected at most 5 events, got ${(feed as any[]).length}`
  );
});

test('fetch_events_feed returns no more than 5 events when more than 5 exist', async () => {
  const admin = createSuperClient();
  const { client: userClient, user } = await setupRandomClientAndLogin();

  await seedEvents(admin, 7, user.id);

  const { data: feed, error } = await userClient
    .rpc('fetch_events_feed', { excluded_ids: [] });

  assert.equal(error, null, `RPC error: ${error?.message}`);
  assert(Array.isArray(feed), 'Expected an array');
  assert(
    feed.length <= 5,
    `Expected at most 5 events, got ${feed.length}`
  );
});

test('fetch_events_feed excludes the IDs passed in excluded_ids', async () => {
  const admin      = createSuperClient();
  const { client: userClient, user } = await setupRandomClientAndLogin();

  const seeded = await seedEvents(admin, 5, user.id);

  const excluded = [seeded[1].id, seeded[3].id];

  const { data: feed, error } = await userClient
    .rpc('fetch_events_feed', { excluded_ids: excluded });

  assert.equal(error, null, `RPC error: ${error?.message}`);
  const feedIds = (feed as any[]).map(e => e.id);

  excluded.forEach(id => {
    assert(!feedIds.includes(id), `Did not expect excluded event ${id}`);
  });

  assert(feedIds.length <= 5, `Expected ≤5 items, got ${feedIds.length}`);
});

test('decrement_slots_taken when a row is removed from event_joins', async () => {
  const admin = createSuperClient();

  const { user: owner }  = await setupRandomClientAndLogin();
  const { user: joiner } = await setupRandomClientAndLogin();
  const [event] = await seedEvents(admin, 1, owner.id);

  await admin.from('event_joins').insert({ event_id: event.id, user_id: joiner.id });
  const mid = await getSlotsTaken(admin, event.id);
  const { error: leaveErr } = await admin
    .from('event_joins')
    .delete()
    .match({ event_id: event.id, user_id: joiner.id });
  assert.equal(leaveErr, null, `Error deleting join: ${leaveErr?.message}`);

  const after = await getSlotsTaken(admin, event.id);
  assert.strictEqual(
    after,
    mid - 1,
    `Expected slots_taken to go from ${mid} → ${mid - 1}, but got ${after}`
  );
});

test('increment_slots_taken when a new row is added to event_joins', async () => {
  const admin = createSuperClient();

  const { user: owner }  = await setupRandomClientAndLogin();
  const { user: joiner } = await setupRandomClientAndLogin();

  const [event] = await seedEvents(admin, 1, owner.id);
  const before = await getSlotsTaken(admin, event.id);

  const { error: joinErr } = await admin
    .from('event_joins')
    .insert({ event_id: event.id, user_id: joiner.id });
  assert.equal(joinErr, null, `Error inserting join: ${joinErr?.message}`);

  const after = await getSlotsTaken(admin, event.id);
  assert.strictEqual(
    after,
    before + 1,
    `Expected slots_taken to go from ${before} → ${before + 1}, but got ${after}`
  );
});

test('decrement_slots_taken when a row is removed from event_joins', async () => {
  const admin = createSuperClient();

  const { user: owner }  = await setupRandomClientAndLogin();
  const { user: joiner } = await setupRandomClientAndLogin();
  const [event] = await seedEvents(admin, 1, owner.id);

  await admin.from('event_joins').insert({ event_id: event.id, user_id: joiner.id });
  const mid = await getSlotsTaken(admin, event.id);
  const { error: leaveErr } = await admin
    .from('event_joins')
    .delete()
    .match({ event_id: event.id, user_id: joiner.id });
  assert.equal(leaveErr, null, `Error deleting join: ${leaveErr?.message}`);

  const after = await getSlotsTaken(admin, event.id);
  assert.strictEqual(
    after,
    mid - 1,
    `Expected slots_taken to go from ${mid} → ${mid - 1}, but got ${after}`
  );
});

/**
 * Insert `count` events under `userId` using the service‐role client.
 */
async function seedEvents(
    admin: SupabaseClient<any, any, any>,
    count: number,
    userId: string
  ) {
    const nowMs = Date.now();
    const inserted: any[] = [];
  
    for (let i = 0; i < count; i++) {
      // schedule each event i minutes from now
      const startDate = new Date(nowMs + (i + 1) * 60_000);      // +1, +2, … minutes
      const endDate   = new Date(startDate.getTime() + 30_000);  // 30 seconds long
  
      const { data, error } = await admin
        .from('events')
        .insert({
          title:       `Test Event ${i + 1}`,
          description: `Description ${i + 1}`,
          start:       startDate.toISOString(),
          end:         endDate.toISOString(),
          latitude:    0,
          longitude:   0,
          slot_limit:  10,
          user_id:     userId,
        })
        .select('*')
        .single();
  
      if (error) throw new Error(`Error seeding events: ${error.message}`);
      inserted.push(data);
    }
  
    return inserted;
  }

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

/**
 * Helper: read the slots_taken for a given event.
 */
async function getSlotsTaken(
    admin: SupabaseClient,
    eventId: number
  ): Promise<number> {
    const { data, error } = await admin
      .from('events')
      .select('slots_taken')
      .eq('id', eventId)
      .single();
    if (error) throw new Error(`Error fetching slots_taken: ${error.message}`);
    return (data as any).slots_taken as number;
  }