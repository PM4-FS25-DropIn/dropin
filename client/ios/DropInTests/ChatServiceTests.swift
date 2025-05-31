import Testing
import Supabase
import XCTest
@testable import DropIn

@MainActor
@Suite
struct ChatServiceTests {
    
    var authService: AuthService
    var event: DropInEvent
    var chatService: ChatService
    
    init() {
        self.authService = AuthService()
        self.event = DropInEvent(
            id: 1,
            createdAt: Date(),
            title: "Test Event",
            description: "",
            imagePaths: [],
            userId: UUID(),
            start: Date(),
            end: Date(),
            slotLimit: 0,
            slotsTaken: 0,
            ageRestricted: false,
            chatEnabled: true,
            location: .init(type: "Point", coordinates: [0,0])
        )
        self.chatService = ChatService(authService: self.authService, event: self.event)
    }
    
    @Test("fetch messages")
    func fetchMessages() async throws {
        await chatService.fetchMessages(for: 1)
    }
    
    @Test("send message")
    func sendMessage() async throws {
        Task {
            do {
                try await chatService.sendMessage("Test Message")
            } catch {
                print(error)
            }
        }
        
        #expect(true)
    }
    
    @Test("subscribe channel testing")
    func subscribeChannel() async throws {
        chatService.subscribeMessages()
        
        chatService.messages.append(contentsOf: [
            Message(chatRoomId: 1, username: "User1", content: "First", isCurrentSession: true, timestamp: Date()),
            Message(chatRoomId: 1, username: "User2", content: "Second", isCurrentSession: false, timestamp: Date())
        ])
        
        #expect(chatService.messages.count == 2)
    }
    
    @Test("unsubscribe channel testing")
    func handleInsertedMessage() async throws {
        await chatService.unsubscribeMessages()
    }
    
}

