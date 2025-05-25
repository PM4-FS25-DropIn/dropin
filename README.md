<div style="text-align: center;"><img src="./docs/images/icon.webp" width="150px"></div>

# <div style="text-align: center;">DropIn</div>
<div style="text-align: center;">

[![Database CI](https://github.com/PM4-FS25-DropIn/dropin/actions/workflows/ci-database.yml/badge.svg)](https://github.com/PM4-FS25-DropIn/dropin/actions/workflows/ci-database.yml)
[![Swift iOS Client CI](https://github.com/PM4-FS25-DropIn/dropin/actions/workflows/ci-client-swift.yml/badge.svg)](https://github.com/PM4-FS25-DropIn/dropin/actions/workflows/ci-client-swift.yml) [![SonarQube Build](https://github.com/PM4-FS25-DropIn/dropin/actions/workflows/sonarqube.yml/badge.svg)](https://github.com/PM4-FS25-DropIn/dropin/actions/workflows/sonarqube.yml)

</div>
DropIn is a social app designed for spontaneous meetups and short-term events. Users can create events that others can quickly join ("drop in"), with events planned up to 7 days in advance. The platform supports both personal and business-created events, encouraging a dynamic mix of activities. Each event features its own chat and media sharing, allowing participants to stay connected and share their experiences. A swipe or map-based interface lets users easily browse through events happening nearby.

## Availability
DropIn is currently available exclusively on iOS and optimized for iPhones using SwiftUI.
An Android version is not yet available but may be considered in future development stages.
We're committed to delivering the best possible experience on iOS before expanding to other platforms.

## Technologies
* Frontend

  For the frontend, we use Swift 6 and SwiftUI. It connects to the backend using the official Swift Supabase client.


* Backend

  Currently, the entire backend is implemented using [Supabase](https://supabase.com/). We use the Realtime feature for chat functionality and SQL functions to perform specific tasks.

## Building & Running DropIn
### iOS

### Backend
In the backend, there's nothing to build. Still, you can test and run it.
To do anything with DropIn locally or productively, you first need to set up a Supabase instance. For local development, we recommend using the [Supabase CLI](https://supabase.com/docs/guides/local-development) to get started.

Run `supabase start` inside the `./client` directory to start and initialize the database. This should automatically run the migration scripts located in `./client/supabase`. If everything runs correctly, Supabase will show you which migrations it executed and then display the addresses where your local Supabase services are available at.

To run the database tests, navigate to the `./server` directory and run `npm run test:db` or `npm run test-win:db`.

## License
