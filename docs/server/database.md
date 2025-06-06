# Database Scheme

The following ERD shows the core tables used by DropIn.
```mermaid
erDiagram
    public.users {
        character_varying aud 
        timestamp_with_time_zone banned_until 
        timestamp_with_time_zone confirmation_sent_at 
        character_varying confirmation_token 
        timestamp_with_time_zone confirmed_at 
        timestamp_with_time_zone created_at 
        timestamp_with_time_zone deleted_at 
        character_varying email 
        character_varying email_change 
        smallint email_change_confirm_status 
        timestamp_with_time_zone email_change_sent_at 
        character_varying email_change_token_current 
        character_varying email_change_token_new 
        timestamp_with_time_zone email_confirmed_at 
        character_varying encrypted_password 
        uuid id PK 
        uuid instance_id 
        timestamp_with_time_zone invited_at 
        boolean is_anonymous 
        boolean is_sso_user 
        boolean is_super_admin 
        timestamp_with_time_zone last_sign_in_at 
        text phone UK 
        text phone_change 
        timestamp_with_time_zone phone_change_sent_at 
        character_varying phone_change_token 
        timestamp_with_time_zone phone_confirmed_at 
        jsonb raw_app_meta_data 
        jsonb raw_user_meta_data 
        timestamp_with_time_zone reauthentication_sent_at 
        character_varying reauthentication_token 
        timestamp_with_time_zone recovery_sent_at 
        character_varying recovery_token 
        character_varying role 
        timestamp_with_time_zone updated_at 
    }

    public.event_joins {
        timestamp_with_time_zone created_at 
        bigint event_id FK,UK 
        bigint id PK 
        boolean is_host 
        uuid user_id FK,UK 
    }

    public.events {
        boolean age_restricted 
        boolean chat_enabled 
        timestamp_with_time_zone created_at 
        text description 
        timestamp_with_time_zone end 
        bigint id PK 
        ARRAY image_paths 
        double_precision latitude 
        double_precision longitude 
        integer slot_limit 
        integer slots_taken 
        timestamp_with_time_zone start 
        text title 
        timestamp_with_time_zone updated_at 
        uuid user_id FK 
    }

    public.messages {
        bigint chat_room_id FK 
        text content 
        timestamp_with_time_zone created_at 
        uuid id PK 
        text sender_id 
        text session_name 
    }

    public.profiles {
        text avatar_url 
        text city 
        text emojicode 
        uuid id PK,FK 
        timestamp_with_time_zone updated_at 
        text username UK 
    }

    event_joins }o--|| users : "user_id"
    event_joins }o--|| events : "event_id"
    events }o--|| users : "user_id"
    messages }o--|| events : "chat_room_id"
    profiles |o--|| users : "id"
```

We use the authentication service of Supabase, thus we use the ID Provided by the `auth.users` table to identify the user throughout the system.

For each DropIn user a 'profile' is created during the signup process. The profile contains general information about the user, like the path to their username, profile picture and more.

Events and participations in events are managed through the `events` and `event_joins` tables. The messages associated with the event are stored in the `messages` table.

Some things not visible in this diagram. There are tw constraints and functions which are enfored during changes and periodicaly (e.g. the cleanup of old events).

## Change Management
Changes to the database are managed through migrations. The migrations are small sql scripts which are automatically applied to the database during the startup of the docker container.

This behaviour is controlled in the Docker Compose file located at `server/docker`. The migrations themselves can be found in the `client/supabase/migrations` directory.