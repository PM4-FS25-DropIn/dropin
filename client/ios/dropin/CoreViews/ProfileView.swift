import SwiftUI

struct ProfileView: View {

    @State private var headerHeight: CGFloat = 320

    var body: some View {
        ScrollView {

            GeometryReader { geometry in
                headerContainer
                    .ignoresSafeArea(edges: .top)
                    .offset(y: -geometry.frame(in: .global).minY / 1.5)
            }
            .frame(height: headerHeight)  // Set dynamically from the measured content.

            feedSection
                .background(Color(.systemBackground))
                .zIndex(1)  // Ensure the profile header is above the feed section
                .cornerRadius(16)
        }
        .edgesIgnoringSafeArea(.top)
        .onPreferenceChange(HeaderHeightPreferenceKey.self) { newHeight in
            withAnimation(.easeInOut) {
                headerHeight = newHeight
            }
        }
    }

    // MARK: - Header Section
    private var headerContainer: some View {
        VStack(spacing: 0) {
            profileHeader

            bioSection
                .padding(.top, 8)

            Divider()
                .padding(.vertical, 8)
        }
        // Use a background GeometryReader to measure the total height of the header container.
        .background(
            GeometryReader { geo in
                Color.clear
                    .preference(
                        key: HeaderHeightPreferenceKey.self,
                        value: geo.size.height
                    )
            }
        )
    }

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
            Text("NAME")
                .font(.title)
                .fontWeight(.bold)
            Text("@username")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    // Evenly spaced stats row
    private var statsRow: some View {
        HStack {
            statItem(number: "4", label: "Friends")
                .frame(maxWidth: .infinity)
            statItem(number: "9", label: "DropIn invites")
                .frame(maxWidth: .infinity)
            statItem(number: "2", label: "DropIn attended")
                .frame(maxWidth: .infinity)
        }
        .padding(.top, 4)
    }

    // MARK: - Bio Section
    private var bioSection: some View {
        ExpandableText(
            text:
                "This is a long description about the user. It can include hobbies, location, or anything relevant. If the text is very long, it will be collapsed to a maximum of five lines by default. Tap 'Read More' to expand and see all the content, and 'Close' to collapse it back.",
            lineLimit: 2
        )
        .padding(.horizontal)
        .foregroundColor(Color.primary.opacity(0.8))
    }
    
    // MARK: - Feed Section
    private var feedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            DropInFeedView()
            Spacer().frame(height: 40)
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }

    // Helper function for stat items
    private func statItem(number: String, label: String) -> some View {
        VStack {
            Text(number)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - DropInFeedView

// TODO: dynamic data for DropInFeedView
struct DropInFeedView: View {
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

            ForEach(events, id: \.self) { event in
                eventRow(for: event)
            }
        }
    }

    private func eventRow(for event: String) -> some View {
        HStack {
            Rectangle()
                .fill(Color("AccentColor"))  // Custom accent color from Assets
                .frame(width: 60, height: 60)
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(event)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("Short description about this event.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct HeaderHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        // We use the maximum height in case there are multiple children reporting
        value = max(value, nextValue())
    }
}

#Preview {
    ProfileView()
}
