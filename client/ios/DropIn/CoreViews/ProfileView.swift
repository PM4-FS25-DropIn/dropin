import SwiftUI
import Kingfisher

/// Displays the profile of a user.
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
                .offset(y: -geometry.frame(in: .global).minY / 1.5)
            }
            .frame(height: 370)

            feedSection
                .background(Color(.systemBackground))
                .zIndex(1)
                .cornerRadius(16)
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            Task {
                if let user = authService.user {
                    if let username = user.userMetadata["username"]?.value as? String {
                        self.username = username
                    } else {
                        self.username = try await authService.getUsername()
                    }
                    if let profile = authService.profile {
                        self.profile = profile
                    } else {
                        self.profile = try await authService.getProfile()
                    }
                }
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
                .accent.opacity(0.6), Color(.systemBackground),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // The banner image on top of the header
    private var bannerImage: some View {
        Group {
            if let bannerUrl = profile?.bannerUrl {
                KFImage(URL(string: bannerUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipped()
            } else {
                Image("default.event.thumbnail")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipped()
            }
        }
    }

    // Row with the settings button, profile image, and edit button.
    private var headerButtonsRow: some View {
        HStack {
            NavigationLink {
                AboutView()
            } label: {
                Image(systemName: "info.circle.fill")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .padding()
            }
            .padding(.top, 160)
            
            Spacer()
            
            profileImageView
                
            Spacer()
            
            NavigationLink {
                ProfileEditView()
            } label: {
                Image(systemName: "pencil.line")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .padding()
            }
            .padding(.top, 160)
        }
        .padding(.horizontal)

    }

    // The profile image (avatar)
    private var profileImageView: some View {
        Group {
            if let avatarUrl = profile?.avatarUrl {
                KFImage(URL(string: avatarUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(radius: 1)
                    .padding(.top, 110)
            } else {
                Image("default.avatar.placeholder")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(radius: 1)
                    .padding(.top, 110)
            }
        }
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
            statItem(number: "\(profile?.dropinsCreated ?? 0)", label: "DropIns created",sf_icon: "sparkles")
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
                .id(UUID())
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


#Preview {
    ProfileView()
        .environment(AuthService())
        .environment(EventStore())
}
