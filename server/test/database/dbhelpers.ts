import { createClient, SupabaseClient, User } from "@supabase/supabase-js";
import assert from "node:assert";

const url: string = "http://127.0.0.1:54321";
const anon_key: string = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0";
const service_key: string = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU";

export function createClientHelper(): SupabaseClient<any, any, any> {
  return createClient(url, anon_key);
}

export function createSuperClient(): SupabaseClient<any, any, any> {
    return createClient(url, service_key);
}

export interface UserOptions {
    email?: string;
    password?: string;
    extensions: {
        username: string;
        emojicode: string;
        city: string;
    }
};

export async function createUser(client: SupabaseClient<any, any, any>, settings?: UserOptions | null): Promise<{password: string, user: User}> {
    const email = settings?.email || generateRandomString(true) + "@test.test";
    const password = settings?.password || generateRandomString(true);
    let result = await client.auth.signUp({
        email: email,
        password: password,
        options: {
            data: {
                username: settings?.extensions.username || generateRandomString(true),
                emojicode: settings?.extensions.emojicode || generateRandomString(true).substring(0, 41),
                city: settings?.extensions.city || generateRandomString()
            }
        }
    });

    if (result.error) {
        throw new Error("Error creating user: " + result.error.message);
    }

    if (!result.data.user) {
        throw new Error("User creation failed: No user returned");
    }

    return { password, user: result.data.user };
}

/**
 * Creates a new client and creates a new user using random credentials.
 * @return {client: SupabaseClient, user: User} The client and the user created.
 */
export async function setupRandomClientAndLogin(): Promise<{client: SupabaseClient<any, any, any>, user: User}> {
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


export function generateRandomString(addDate: boolean = false): string {
    const length = 10; // Length of the random string
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'; // Characters to choose from
    let result = '';
    for (let i = 0; i < length; i++) {
        const randomIndex = Math.floor(Math.random() * characters.length);
        result += characters.charAt(randomIndex);
    }

    if (addDate) {
        result = new Date().getMilliseconds() + result;
    }

    return result;
}

export const DEFAULT_LOCATION_ASPOSTGIS = "0101000020E610000000000000000049400000000000004940";

export async function createEvent(client: SupabaseClient<any, any, any>): Promise<any> {
    const event_to_create = {
        title: generateRandomString(),
        description: generateRandomString(),
        start: new Date().toISOString(),
        end: new Date(Date.now() + 3600000).toISOString(),
        location:    "POINT(0 0)", 
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
 * Creates a random blob of the given size and type.
 * @param size The size of the blob in bytes.
 * @param type The type of the blob. Default is 'image/png'.
 * @returns {Blob} The created blob.
 */
export function generateRandomBlob(size: number, type: string = 'image/png'): Blob {
    return new Blob([new ArrayBuffer(size)], { type });
};