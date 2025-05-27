# Architectural Proposal for DropIn

**Owned by Leo Boedi**
**Apr 02, 2025**
*2 min read*

*See how many people viewed this*

## Overview
DropIn utilizes a clear client-backend architecture, designed to be robust, maintainable, and scalable. The system consists of a dedicated client-side iOS application that interacts directly with Supabase for its backend functionalities. Data persistence, real-time features, and authentication are managed through self hosted Supabase instance using Docker.

## Architecture Breakdown

### Client-Side (iOS Application)
The client-side architecture follows a modular approach using specialized service classes, enhancing maintainability and separation of concerns. Each service class addresses a specific domain within the app. These services are injected into the environment at the root view, providing global accessibility to all child views.

**Service Classes:**
*   **`EventService`**: Responsible for handling event-related operations such as creating, updating, fetching, deleting, and allowing users to join events. It interacts directly with Supabase for database operations and real-time updates concerning events.
*   **`AuthService`**: Manages user authentication and session management, including user signup, login, and session validation. This service communicates directly with Supabase's authentication system.
*   **`ChatService`**: Handles real-time chat functionalities, including messaging, chat room creation, and subscription management. It interfaces directly with Supabase for real-time updates.

### Backend Infrastructure (Supabase)
Supabase serves as the comprehensive backend solution, directly handling data storage, real-time updates, and authentication. The iOS client interacts with Supabase via its SDKs.

*   **Database**: Supabase's PostgreSQL database stores all application data, including events, user information, and chat messages. Row-Level Security (RLS) policies are implemented to ensure data privacy and integrity.
*   **Real-time Functionality**: Supabase's real-time capabilities are leveraged by `EventService` and `ChatService` for live updates on event changes, new messages, and other dynamic data.
*   **Authentication**: Supabase's built-in authentication system manages user sign-up, login, session validation, and provides secure user identity management.

### Notifications
To optimize performance and reduce complexity, the DropIn app leverages client-side generated notifications. Most notifications, including proximity-based notifications triggered when a user is near an event, are managed directly by the iOS client application. The app regularly polls event data from Supabase at fixed intervals, checking locally if conditions for notifications are met. This approach minimizes latency and simplifies the backend.

## Conclusion
This architectural setup, centered around the iOS client and Supabase, is designed to offer a reliable, efficient, and scalable platform. It ensures an excellent user experience and simplifies future development and maintenance efforts by leveraging Supabase's integrated backend-as-a-service features.