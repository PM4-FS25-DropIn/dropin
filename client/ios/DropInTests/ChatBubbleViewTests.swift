import SwiftUI
import Testing
@testable import DropIn

@Suite("Chat Bubble View Tests")
struct ChatBubbleViewTests {

    @Test("Timestamp formatting output is not empty")
    func timeStampFormattingOutputIsNotEmpty() {
        let date = Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 14, hour:15, minute: 30))!
        let message = Message(chatRoomId: 1, username: "Tester", content: "Hello", isCurrentSession: false, timestamp: date)
        let formatted = message.formattedTimestamp()
    
        #expect(!formatted.isEmpty)
    }
}
