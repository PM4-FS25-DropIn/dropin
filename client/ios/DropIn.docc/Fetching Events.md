# Fetching Events

Learn how DropIn retrieves and manages nearby events using a geospatially optimized backend and a centralized in-app event store.

## Overview

DropIn delivers a dynamic, location-aware event feed powered by an efficient and scalable event fetching mechanism. This mechanism ensures users see relevant events—both nearby and timely—whether they are browsing the map or scrolling through their home feed.

At the heart of this system is the **`EventStore`**, a centralized, observable manager responsible for retrieving events from the backend and maintaining an up-to-date local cache for UI components to consume.

## How Event Fetching Works

### 1. Centralized Event Management

All events in the app are managed through an environment shared instance of `EventStore`. This class:

- Fetches events from the backend (Supabase)
- Caches them locally in-memory
- Provides filtered subsets of events to views (e.g., joined events, nearby unjoined events)
- Prunes expired events automatically

This centralization ensures a consistent and performant experience across all views, while keeping network traffic minimal.

### 2. Efficient Geo-Queries with PostGIS

The backend is backed by PostgreSQL with [PostGIS](https://postgis.net/) enabled for spatial data support. Each event in the `events` table stores its location as a `geography` type column, enabling highly optimized spatial queries.

To find nearby events, the frontend calls a **remote procedure (RPC)** function exposed by Supabase. This function takes:

- A **center coordinate** (`latitude`, `longitude`)
- A **search region** (`latitudeDelta`, `longitudeDelta`)

Using spatial indexes on the location column, the RPC efficiently returns only events within the specified bounding box. This ensures low-latency queries, even with a large event dataset.

### 3. View-Specific Fetching Behavior

#### Home View (Feed)

- Initially fetches events around the user's location using a small delta.
- As the user scrolls through the event list, the `EventStore` detects when more data is needed.
- It then **increments the search delta**, effectively expanding the radius and fetching more events outward from the user’s location.

This creates an "infinite scroll" experience, while prioritizing nearby events first.

#### Map View

- Events are fetched based on the **currently visible map camera region**.
- Every time the map moves significantly, a new query is made with the updated center and span values.
- This ensures that the user always sees relevant, up-to-date event pins in their current view.

### 4. Filtering and Deduplication

Once events are fetched:

- Already-joined events are excluded from the general nearby feed.
- Expired events (whose `end` time is in the past) are automatically pruned.
- Duplicate fetches are avoided by comparing against previously fetched event IDs.

## Extensibility & Performance

The fetching system is designed with scalability in mind:

- The spatial RPC query can be easily adapted to support filters (e.g., categories, time ranges).
- Fetching logic is wrapped in async functions for seamless integration with Swift concurrency.
- The search delta approach in the home view gracefully balances **performance** and **relevance**.

## Conclusion

By combining a smart client-side store (`EventStore`) with a geospatially optimized backend, DropIn ensures that users discover nearby events in a responsive and efficient way—whether they’re exploring spontaneously via the map or browsing curated lists in the home feed.

This architecture lays a solid foundation for future growth, such as personalized sorting, trending events, or live filtering—all while keeping user experience fast and fluid.
