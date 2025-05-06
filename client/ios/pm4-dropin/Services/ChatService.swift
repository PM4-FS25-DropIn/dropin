import Foundation
import Auth
import Supabase

@MainActor
final class ChatService: ObservableObject {
    
    private let authService: AuthService
    //@Published private(set) var currentUser: Profile?
    @Published var messages: [Message] = []
    private var channel: RealtimeChannelV2?

    private let eventId: Int
    
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
    
    
    init(authService: AuthService, event: DropInEvent) {
        self.authService = authService
        // TODO: Handle error
        guard let id = event.id else {
            self.eventId = 0
            return
        }
        self.eventId = id
        
        Task {
            //await loadCurrentUser()
            await fetchMessages(for: eventId)
        }
    }

    
    /*func loadCurrentUser() async {
        do {
            currentUser = try await authService.getUser()
        } catch {
            print("Failed to load current user: \(error)")
        }
    }*/

    func fetchMessages(for eventId: Int) async {
        do {
            //guard let user = currentUser else { return }
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

    func sendMessage(_ content: String) async throws {
        do {
            //guard let user = currentUser else { return }
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
    
    func unsubscribeMessages() async {
        if let channel = channel {
            await supabase.removeChannel(channel)
            self.channel = nil
        }
    }

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
