import SwiftUI

// MARK: - Data Model

struct Chat: Identifiable {
    let id = UUID() // Conforms to Identifiable for ForEach
    let groupName: String
    let lastMessage: String
    let lastMessageTimestamp: Date
    let unreadCount: Int
    // No profileImageURL needed yet, using placeholder
}

// MARK: - Chats View

struct ChatsView: View {

    // State variable to hold our dummy chat data
    @State private var chats: [Chat] = []

    var body: some View {
        // Use NavigationStack for modern navigation
        NavigationStack {
            // List provides efficient scrolling for rows
            List {
                // Iterate over the chats data
                ForEach(chats) { chat in
                    // NavigationLink makes the row tappable
                    NavigationLink {
                        // Placeholder destination view for when a chat is tapped
                        ChatDetailPlaceholderView(groupName: chat.groupName)
                    } label: {
                        // Custom view for how each chat row looks
                        ChatRow(chat: chat)
                    }
                }
            }
            .listStyle(.plain) // Optional: Removes default inset grouped styling
            .navigationTitle("Chats") // Sets the title in the navigation bar
            .onAppear(perform: loadDummyData) // Load data when the view appears
        }
    }

    // MARK: - Data Loading

    // Function to populate the chats array with dummy data
    private func loadDummyData() {
        // Simulate fetching data (replace with actual fetch later)
        chats = [
            Chat(groupName: "Weekend BBQ Crew",
                 lastMessage: "Sounds good! See you Saturday.",
                 lastMessageTimestamp: Calendar.current.date(byAdding: .minute, value: -5, to: Date())!, // 5 mins ago
                 unreadCount: 2),
            Chat(groupName: "Project Phoenix Team",
                 lastMessage: "Meeting notes are uploaded.",
                 lastMessageTimestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!, // 2 hours ago
                 unreadCount: 0),
            Chat(groupName: "Hiking Trip Planning",
                 lastMessage: "Don't forget your water bottles!",
                 lastMessageTimestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, // Yesterday
                 unreadCount: 5),
            Chat(groupName: "Book Club",
                 lastMessage: "What did everyone think of the ending?",
                 lastMessageTimestamp: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, // 3 days ago
                 unreadCount: 0),
            Chat(groupName: "Apartment Neighbors",
                 lastMessage: "Package for Apt 3B at the front desk.",
                 lastMessageTimestamp: Calendar.current.date(byAdding: .minute, value: -35, to: Date())!, // 35 mins ago
                 unreadCount: 1)
        ]
    }
}

// MARK: - Chat Row View

struct ChatRow: View {
    let chat: Chat

    var body: some View {
        HStack(spacing: 15) {
            // Profile Picture Placeholder
            Circle()
                .fill(.gray.opacity(0.8)) // Blank gray circle
                .frame(width: 50, height: 50)

            // Group Name and Last Message Preview
            VStack(alignment: .leading, spacing: 4) {
                Text(chat.groupName)
                    .font(.headline)
                    .lineLimit(1) // Ensure group name doesn't wrap excessively

                Text(chat.lastMessage)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1) // Show only one line of the last message
            }

            Spacer() // Pushes timestamp and badge to the right

            // Timestamp and Unread Count Badge
            VStack(alignment: .trailing, spacing: 5) {
                Text(formatDate(chat.lastMessageTimestamp))
                    .font(.caption)
                    .foregroundColor(.gray)

                // Display unread count badge only if count > 0
                if chat.unreadCount > 0 {
                    ZStack {
                        Circle()
                            .fill(.blue)
                        Text("\(chat.unreadCount)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .frame(width: 20, height: 20) // Fixed size for the badge
                } else {
                    // Keep the space consistent even if no badge
                    Spacer().frame(height: 20)
                }
            }
        }
        .padding(.vertical, 5) // Add some vertical padding to each row
    }

    // Helper function to format the date nicely
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            // If today, show time
            return date.formatted(date: .omitted, time: .shortened)
        } else if calendar.isDateInYesterday(date) {
            // If yesterday, show "Yesterday"
            return "Yesterday"
        } else {
            // Otherwise, show short date (e.g., "1/23/24")
            return date.formatted(date: .numeric, time: .omitted)
        }
    }
}

// MARK: - Placeholder Detail View

struct ChatDetailPlaceholderView: View {
    let groupName: String

    var body: some View {
        Text("Chat Detail for \(groupName)")
            .navigationTitle(groupName)
            .navigationBarTitleDisplayMode(.inline) // Optional: smaller title
    }
}


// MARK: - Preview

#Preview {
    ChatsView()
}
