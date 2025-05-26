import SwiftUI


struct ProfileView: View {
    
    @Environment(AuthService.self) private var authService
    @Environment(EventStore.self) private var eventStore
    
    @State private var username: String = "Loading..."
    @State private var profile: Profile? = nil

    var body: some View {
        ScrollView {

            GeometryReader { geometry in
                VStack(spacing: 0) {
                    profileHeader
                    Divider()
                        .padding(.vertical, 16)
                }
                .offset(y: -geometry.frame(in: .global).minY / 1.5)  // Header will move slower than the scroll -> offset correction
            }
            .frame(height: 370)

            feedSection
                .background(Color(.systemBackground))
                .zIndex(1)  // Ensure the profile header is above the feed section
                .cornerRadius(16)
            
            Button("Sign out") {
                            Task {
                                try await authService.signOut()
                            }
                        }
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            Task {
                print("Getting username")
                profile = try await authService.getProfile()
                username = profile?.username ?? "Unnamed"
                print("Username is: \(username)")
            }
        }
    }

    // MARK: - Header Section

    private var profileHeader: some View {
        ZStack(alignment: .top) {
            backgroundGradient
            bannerImage

            VStack(spacing: 8) {
                headerButtonsRow
                nameAndUsername
                statsRow
            }
            .frame(maxWidth: .infinity)
        }
    }

    // The background gradient that fades from AccentColor to the system background
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color("AccentColor"), Color(.systemBackground),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // The banner image on top of the header
    private var bannerImage: some View {
        Image("account_banner_placeholder")
            .resizable()
            .scaledToFill()
            .frame(height: 160)
            .clipped()
    }

    // Row with the settings button, profile image, and edit button.
    private var headerButtonsRow: some View {
        HStack {
            settingsButton
            Spacer()
            profileImageView
            Spacer()
            editButton
        }
        .padding(.horizontal)
    }

    private var settingsButton: some View {
        Button(action: {
            // TODO: Navigate to settings
        }) {
            Image(systemName: "gearshape.fill")
                .font(.title2)
                .foregroundColor(.primary)
                .padding()
        }
        .padding(.top, 160)
    }

    private var editButton: some View {
        Button(action: {
            // TODO: Edit profile action
        }) {
            Image(systemName: "pencil.line")
                .font(.title2)
                .foregroundColor(.primary)
                .padding()
        }
        .padding(.top, 160)
    }

    // The profile image (avatar)
    private var profileImageView: some View {
        Image("profile_avatar_placeholder")
            .resizable()
            .scaledToFill()
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(Color("AccentColor"), lineWidth: 6)
            )
            .shadow(radius: 1)
            .padding(.top, 110)
    }

    // Name and username texts
    private var nameAndUsername: some View {
        VStack {
            Text("\(username)")
                .font(.title)
                .fontWeight(.bold)
            Text("@\(username)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    

    // Evenly spaced stats row
    private var statsRow: some View {
        HStack {
            statItem(number: "\(profile?.dropinsCreated ?? 0)", label: "DropIns Created",sf_icon: "sparkles")
                .frame(maxWidth: .infinity)
            statItem(number: "\(profile?.dropinsJoined ?? 0)", label: "DropIns attended",sf_icon: "figure.wave")
                .frame(maxWidth: .infinity)
        }
        .padding(.top, 4)
    }

    // MARK: - Feed Section
    private var feedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            DropInFeedView()
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }

    // Helper function for stat items
    private func statItem(number: String, label: String, sf_icon: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: sf_icon)
                    .font(.headline)
                    .foregroundColor(.accentColor)
                Text(number)
                    .font(.headline)
            }
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - DropInFeedView

// TODO: dynamic data for DropInFeedView
struct DropInFeedView: View {
    @Environment(AuthService.self) private var authService
    @Environment(EventStore.self) private var eventStore

    // Example placeholder data
    let events = [
        "My Beach Party",
        "Coding Hangout",
        "Birthday Bash",
        "Movie Night",
        "Brunch Meet",
        "My Beach Party",
        "Coding Hangout",
        "Birthday Bash",
        "Movie Night",
        "Brunch Meet",
        "My Beach Party",
        "Coding Hangout",
        "Birthday Bash",
        "Movie Night",
        "Brunch Meet",
    ]

    var body: some View {
        
        
        VStack(alignment: .leading, spacing: 8) {
            Text("My DropIns")
                .font(.headline)

            if eventStore.fetchEventsOfUser().isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "party.popper.fill")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No DropIns yet...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(eventStore.fetchEventsOfUser()) { event in
                    eventRow(for: event)
                }
            }
        }

    }
    

    private func eventRow(for event: DropInEvent) -> some View {
        HStack {
            AsyncImage(url: URL(string: event.imagePaths[0])) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else if phase.error != nil {
                        VStack(spacing: 5) {
                            Image(systemName: "exclamationmark.circle.fill")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .scaledToFill()
                        .containerRelativeFrame([.horizontal], count: 10, span: 4, spacing: 0)
                        .clipped()
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 60, height: 60)
                .clipped()
                .cornerRadius(8)
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(event.description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }
}

#Preview {
    ProfileView()
        .environment(AuthService())
        .environment(EventStore())
}
