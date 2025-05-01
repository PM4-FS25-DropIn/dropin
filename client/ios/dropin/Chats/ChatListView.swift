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

struct ChatListView: View {

    // State variable to hold our dummy chat data
    @State private var chats: [Chat] = []
    @State private var events: [DropInEvent] = []
    @Environment(AuthService.self) private var authService

    var body: some View {
        NavigationStack {
            List {
                ForEach(events) { event in
                    NavigationLink {
                        // Placeholder destination view for when a chat is tapped
                        ChatRoomView(event: event, authService: authService)
                        
                    } label: {
                        // Custom view for how each chat row looks
                        ChatRow(event: event)
                    }
                }
            }
            .listStyle(.plain) // Optional: Removes default inset grouped styling
            .navigationTitle("Chats") // Sets the title in the navigation bar
            .onAppear(perform: loadDummyEvents) // Load data when the view appears
        }
    }

    // MARK: - Data Loading

    
    private func loadDummyEvents() {
        events = [
            DropInEvent(
                id: 1,
                createdAt: Date(),
                title: "Pizza Night",
                description: "Join us for free pizza and chill vibes.",
                imagePaths: ["pizza.jpg"],
                userId: UUID(),
                start: Calendar.current.date(byAdding: .hour, value: 1, to: Date())!,
                end: Calendar.current.date(byAdding: .hour, value: 3, to: Date())!,
                latitude: 47.3769,
                longitude: 8.5417,
                maxSlots: 10,
                takenSlots: 3,
                visibility: .public,
                ageRestricted: false,
                chatEnabled: true,
                status: .upcoming
            ),
            DropInEvent(
                id: 2,
                createdAt: Date(),
                title: "Sunset Hike",
                description: "Evening hike with a view. Bring water!",
                imagePaths: ["hike.jpg"],
                userId: UUID(),
                start: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
                end: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.date(byAdding: .hour, value: 2, to: Date())!)!,
                latitude: 47.2654,
                longitude: 8.6741,
                maxSlots: 15,
                takenSlots: 12,
                visibility: .public,
                ageRestricted: false,
                chatEnabled: true,
                status: .upcoming
            ),
            DropInEvent(
                id: 3,
                createdAt: Date(),
                title: "Late Night Coding",
                description: "Bring your laptop and snacks. We'll build something cool.",
                imagePaths: ["coding.jpg"],
                userId: UUID(),
                start: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
                end: Calendar.current.date(byAdding: .hour, value: 2, to: Date())!,
                latitude: 47.5000,
                longitude: 8.3500,
                maxSlots: 8,
                takenSlots: 8,
                visibility: .public,
                ageRestricted: true,
                chatEnabled: true,
                status: .live
            )
        ]
    }
}

// MARK: - Chat Row View

struct ChatRow: View {
    let event: DropInEvent

    var body: some View {
        HStack(spacing: 10) {
            groupImage
            chatPreview
            Spacer()
            timestampAndBadge
        }
        .padding(.vertical, 5)
    }

    private var groupImage: some View {
        Circle()
            .fill(.gray.opacity(0.8))
            .frame(width: 50, height: 50)
    }

    private var chatPreview: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.title)
                .font(.headline)
                .lineLimit(1)
            //Text(chat.lastMessage)
            //  .font(.subheadline)
            //.foregroundColor(.gray)
            // .lineLimit(1)
        }
    }

    private var timestampAndBadge: some View {
        VStack(alignment: .trailing, spacing: 5) {
            Text(formatDate(Calendar.current.date(byAdding: .minute, value: -35, to: Date())!))
                .font(.caption)
                .foregroundColor(.gray)

            if 5 > 0 {
                ZStack {
                    Circle()
                        .fill(.blue)
                    Text("\(2)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .frame(width: 20, height: 20)
            } else {
                Spacer().frame(height: 20)
            }
        }
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


// MARK: - Preview

#Preview {
    ChatListView()
}
