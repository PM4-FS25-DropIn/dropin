import SwiftUI
import Kingfisher


/// A list of the temporary event chats.
struct ChatListView: View {
    @Environment(AuthService.self) private var authService
    @Environment(EventStore.self) private var eventStore

    var body: some View {
        List {
            ForEach(eventStore.joinedEvents) { event in
                NavigationLink {
                    ChatRoomView(event: event, authService: authService)
                    
                } label: {
                    ChatRow(event: event)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Chats")
    }

    
}

// MARK: - Chat Row View

/// A single chat row used in a list.
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
        eventImageCircle
    }

    private var chatPreview: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.title)
                .font(.headline)
                .lineLimit(1)
        }
    }
    
    private var eventImageCircle: some View {
        Group {
            if let eventImagePath = event.imagePaths?.first {
                KFImage(URL(string: eventImagePath)!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Image("defaut.event.thumbnail")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
        }
    }

    private var timestampAndBadge: some View {
        VStack(alignment: .trailing, spacing: 5) {
            Text(formatDate(Calendar.current.date(byAdding: .minute, value: -35, to: Date())!))
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return date.formatted(date: .omitted, time: .shortened)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(date: .numeric, time: .omitted)
        }
    }
}

