import SwiftUI

// MARK: - Chats View

struct ChatListView: View {
    @Environment(AuthService.self) private var authService
    @Environment(EventStore.self) private var eventStore

    var body: some View {
        NavigationStack {
            List {
                ForEach(eventStore.joinedEvents) { event in
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
            .navigationTitle("Chats")
        }
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

