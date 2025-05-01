import { createClient, SupabaseClient, User } from "@supabase/supabase-js";

const url: string = "http://127.0.0.1:54321";
const key: string = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0";

export function createClientHelper(): SupabaseClient<any, any, any> {
  return createClient(url, key);
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