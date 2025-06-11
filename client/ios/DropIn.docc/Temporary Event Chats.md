# Temporary Event Chats

An overview of how DropIn enables spontaneous, short-lived group messaging around live events using Supabase Realtime.

## Overview

Every event in DropIn comes with its own **temporary chat room**—a place where participants can communicate spontaneously during the course of the event. These chats are designed to be lightweight, ephemeral, and directly tied to the lifecycle of the event they belong to.

## Key Characteristics

- **Scoped to Events**: Each chat is uniquely linked to a DropIn event.
- **Temporary by Design**: Chat rooms only exist while the event is active. Messages are not persisted beyond the event’s lifetime.
- **Realtime Communication**: Built using **Supabase Realtime**, allowing instant delivery of new messages to all active clients.

## Architecture

### 1. Message Model

Messages are stored in a dedicated table and include fields such as:

- `sender_id`
- `chat_room_id` (linked to the event)
- `content`
- `created_at`

A `MessageDTO` (data transfer object) maps raw database records to the app’s internal `Message` model for UI rendering.

### 2. Supabase Realtime Subscription

Each client subscribes to **insert events** for the `messages` table using Supabase Realtime:

```swift
supabase.channel("messages:event_123")
    .on("postgres_changes", filter: .insert, table: "messages")
    .subscribe()
```

Upon receiving new messages, the UI is updated immediately using a published `@Observable` message list, ensuring low-latency group communication.

### 3. Message Sending

When a user sends a message:

- It is written to the `messages` table with appropriate metadata.
- Supabase Realtime broadcasts the insert to all subscribed clients in the room.
- The local `ChatService` handles formatting and pushing the new message into the in-memory view model.

### 4. Lifecycle Management

Chat channels are automatically:

- **Joined** when a user enters the event view.
- **Unsubscribed** when the view is dismissed or the event ends.
- Future optimizations may include automatic cleanup or memory-safe purging for long-running sessions.

## Benefits

- **Ephemeral by nature**: Encourages lightweight communication around the moment.
- **Scalable**: Based on database triggers and WebSocket connections, with minimal backend logic.
- **Minimal setup**: No external messaging service required—fully powered by Supabase.

## Future Considerations

- Implement message expiration or automatic purging at the database level.
- Allow ephemeral attachments (images, links) in messages.
- Support rich text or emoji reactions with structured formatting.

## Conclusion

Temporary event chats provide DropIn users with a spontaneous and real-time way to engage during events. By leveraging Supabase Realtime and lightweight design principles, the system is fast, flexible, and well-suited for short-lived group conversations.
