
import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(spacing: 0) {
            
            profileHeader
            
            bioSection
            
            Divider()
                .padding(.vertical, 16)
            
            feedSection
        }
        .ignoresSafeArea(edges: .top)  // Allow the header (wallpaper) to extend under the status bar
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
            gradient: Gradient(colors: [Color("AccentColor"), Color(.systemBackground)]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()  // Make sure the gradient covers the full screen area
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
                .foregroundColor(.white)
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
                .foregroundColor(.white)
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
        Text("This is a short description about the user. It can include hobbies, location, or anything relevant.")
            .font(.body)
    }
    
    // MARK: - Feed Section
    private var feedSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DropInFeedView()
                Spacer().frame(height: 40)
            }
            .padding(.horizontal)
        }
    }
    
    // Helper function for stat items
    @ViewBuilder
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
        "Brunch Meet"
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

#Preview {
    ProfileView()
}
