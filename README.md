<div align="center"><img src="./docs/images/icon.webp" width="150px"></div>

# <div align="center">DropIn</div>
<div align="center">

[![Database CI](https://github.com/PM4-FS25-DropIn/dropin/actions/workflows/ci-database.yml/badge.svg)](https://github.com/PM4-FS25-DropIn/dropin/actions/workflows/ci-database.yml)
[![Swift iOS Client CI](https://github.com/PM4-FS25-DropIn/dropin/actions/workflows/ci-client-swift.yml/badge.svg)](https://github.com/PM4-FS25-DropIn/dropin/actions/workflows/ci-client-swift.yml) [![SonarQube Build](https://github.com/PM4-FS25-DropIn/dropin/actions/workflows/sonarqube.yml/badge.svg)](https://github.com/PM4-FS25-DropIn/dropin/actions/workflows/sonarqube.yml)

</div>
DropIn is a social app designed for spontaneous meetups and short-term events. Users can create events that others can quickly join ("drop in"). The platform supports both personal and business-created events, encouraging a dynamic mix of activities. Each event features its own chat and media sharing, allowing participants to stay connected and share their experiences. A swipe or map-based interface lets users easily browse through events happening nearby.

## Availability
DropIn is currently available exclusively on iOS and optimized for iPhones using SwiftUI.
An Android version is not yet available but may be added in future development stages.
We're committed to delivering the best possible experience on iOS before expanding to other platforms.

## Landing Page

[DropIn](https://dropinwith.me)

## Technologies
* Frontend

  For the frontend, we use Swift 6 and SwiftUI. It connects to the backend using the official Swift Supabase client.


* Backend

  Currently, the entire backend is implemented using [Supabase](https://supabase.com/). We use the Realtime feature for chat functionality and SQL functions to perform specific tasks.

## Contributing
Found a bug or want to contribute? Feel free to report an issue and or pick up an open issue!

## Building & Running DropIn
To build and run DropIn you first have to clone the repository. To do so run the following command in your console:

```
git clone git@github.com:PM4-FS25-DropIn/dropin.git
```

### iOS
To build the DropIn iOS app, open the client directory in Xcode and build the project.
After a successful build, the emulator should launch and display the app.

### Backend
In the backend, there's nothing to build. While there's nothing to compile, you can still test and run the backend locally.
To do anything with DropIn locally or productively, you first need to set up a Supabase instance. For local development, we recommend using the [Supabase CLI](https://supabase.com/docs/guides/local-development) to get started.

Run `supabase start` inside the `./client` directory to start and initialize the database. This should automatically run the migration scripts located in `./client/supabase`. If everything runs correctly, Supabase will show you which migrations it executed and then display the addresses where your local Supabase services are available at.

To run the database tests, navigate to the `./server` directory and run `npm run test:db` or `npm run test-win:db`.

## Testing

Testing was an essential part of our development workflow to ensure reliability and maintainability of DropIn. Our testing strategy covered both backend and client-side components through a combination of automated unit tests, integration tests, and end-to-end (E2E) UI tests.

### CI/CD Integration

We integrated the following tools into our CI pipeline:

- **GitHub Actions**  
  Used for running backend database integration tests and unit tests. These tests were triggered on every pull request into the `dev` branch.
  
- **Xcode Cloud**  
  Used to automatically run the iOS test suites, including:
  - Unit tests for critical service components (e.g. `AuthService`, `ChatService`)
  - UI E2E tests simulating user workflows
  - Performance and startup-time tests on real devices

All test pipelines were triggered on PRs into the `dev` branch.

### Test Deployment & Manual QA

After each successful merge into `dev`, the iOS app was automatically built and deployed via **TestFlight**. This allowed us to test the app manually on devices to catch bugs and performance issues that might not be visible in automated test environments.

### Code Coverage & Test Focus

While the **overall coverage** of the app may appear low, this is primarily due to the large number of declarative UI components that don't benefit from traditional unit testing.

Instead, our focus was on:

- **Unit testing the parts that matter**: primarily service components that manage business and data logic
- **Running those tests against a hosted test database** to verify API correctness
- **Covering UI workflows** through automated E2E tests in Xcode Cloud

This approach ensured meaningful coverage of critical areas without overengineering flaky or redundant tests.

### Test Reports

You can find the latest testing reports and overviews in the [`/reports`](./reports) directory.

## Documentation

Here you can find more detailed documentation about the project:

- [Team](./docs/Team.md)
- [Feature Specifications](./docs/FeatureSpecifications.md)
- [Client Visual Concept](./docs/client/VisualConcept.md)
- [Server Architecture](./docs/server/Architecture.md)
- [Supabase Deployment and Configuration](./docs/server/SupabaseDeploymentAndConfiguration.md)
- [Definition of Done](./docs/DefinitionOfDone.md)

### App Documentation

[App Documentation](https://pm4-fs25-dropin.github.io/dropin-docs/documentation/dropin/)
