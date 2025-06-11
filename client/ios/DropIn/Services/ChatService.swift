import Foundation
import Auth
import Supabase

/// A service responsible for managing real-time chat functionality,
/// including message retrieval, sending, and live updates for a specific DropIn event.
@MainActor
@Observable
final class ChatService {
    
    /// The authentication service used to retrieve user session information.
    private let authService: AuthService
    /// The list of chat messages for the current event.
    var messages: [Message] = []
    /// The real-time channel used for receiving live message updates.
    private var channel: RealtimeChannelV2?

    /// The ID of the DropIn event associated with this chat session.
    private let eventId: Int
    
    /// The current event. Fetches messages automatically when set.
    var event: DropInEvent? {
        didSet {
            if let event = event {
                Task {
                    guard let id = event.id else { return }
                    await fetchMessages(for: id)
                    
                }
            }
        }
    }
    
    
    /// Initializes the ChatService with an AuthService and a DropInEvent.
    /// Automatically fetches messages for the provided event.
    init(authService: AuthService, event: DropInEvent) {
        self.authService = authService
        // TODO: Handle error
        guard let id = event.id else {
            self.eventId = 0
            return
        }
        self.eventId = id
        
        Task {
            await fetchMessages(for: eventId)
        }
    }

    /// Fetches the latest messages for the given event ID from Supabase.
    /// - Parameter eventId: The ID of the event whose messages should be retrieved.
    func fetchMessages(for eventId: Int) async {
        do {
            let sessionId = authService.userId
            guard let sessionId else { return } // TODO: handle error
            let data: [MessageDTO] = try await supabase
                .from("messages")
                .select()
                .eq("chat_room_id", value: eventId)
                .order("created_at", ascending: true)
                .limit(100)
                .execute()
                .value
            messages = data.map { $0.toModel(currentSessionId: sessionId) }
        } catch {
            dump(error)
        }
    }

    /// Sends a new message to the current event's chat room.
    /// - Parameter content: The message content to send.
    func sendMessage(_ content: String) async throws {
        do {
            guard let userId = authService.userId, let userName = try? await authService.getUsername() else { return }
            let data = MessageDTO(
                sender_id: userId,
                session_name: userName,
                content: content,
                created_at: Date(),
                chat_room_id: eventId
            )
            let _ = try await supabase.from("messages").insert(data).execute()
        } catch {
            throw error
        }
    }

    /// Subscribes to real-time message insertions for the messages table.
    /// Automatically handles new incoming messages.
    func subscribeMessages() {
        let channel = supabase.realtimeV2.channel("public:messages")
        self.channel = channel
        
        let insertions = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "messages"
        )
        
        Task {
            await channel.subscribe()
            for await insertion in insertions {
                await handleInserted(insertion)
            }
        }
    }
    
    /// Unsubscribes from the real-time message channel.
    func unsubscribeMessages() async {
        if let channel = channel {
            await supabase.removeChannel(channel)
            self.channel = nil
        }
    }

    /// Handles a new message inserted via the real-time channel and appends it to the message list.
    /// - Parameter action: The real-time insertion action containing the new message data.
    func handleInserted(_ action: HasRecord) async {
        do {
            guard let userId = authService.userId else { return }
            let sessionId = userId
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decodedMessage = try action.decodeRecord(decoder: decoder) as MessageDTO
            guard Int(decodedMessage.chat_room_id) == eventId else { return }
            let message = decodedMessage.toModel(currentSessionId: sessionId)
            messages.append(message)
        } catch {
            dump(error)
        }
    }
}
