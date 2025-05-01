import Foundation
import CoreLocation
import SwiftUI

struct Profile: Decodable {
    let id: UUID
    let username: String
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case avatarUrl = "avatar_url"
    }
}

struct UpdateProfileParams: Encodable {
  let username: String
  let fullName: String
  let website: String

  enum CodingKeys: String, CodingKey {
    case username
    case fullName = "full_name"
    case website
  }
}

struct Message: Identifiable, Equatable {
    let id: UUID = UUID()
    let chatRoomId: Int
    let username: String
    let content: String
    let isCurrentSession: Bool
    let timestamp: Date
    
    static let formatter = DateFormatter()
    
    func formattedTimestamp() -> String {
        Self.formatter.dateStyle = .none
        Self.formatter.timeStyle = .short
        return Self.formatter.string(from: timestamp)
    }
    
    func formattedDate() -> String {
        Self.formatter.dateStyle = .medium
        Self.formatter.timeStyle = .none
        return Self.formatter.string(from: timestamp)
    }
}

struct MessageDTO: Codable {
    let sender_id: UUID
    let session_name: String
    let content: String
    let created_at: Date
    let chat_room_id: Int
    
    func toModel(currentSessionId: UUID) -> Message {
        .init(
            chatRoomId: chat_room_id,
            username: session_name,
            content: content,
            isCurrentSession: sender_id == currentSessionId,
            timestamp: created_at
        )
    }
}

struct ChatRoom: Identifiable {
    let id: UUID
    let eventId: UUID
    let createdAt: Date
}


enum EventCategory: String, CaseIterable {
    case forYou = "For You"
    case trending = "Trending"
    case nearby = "Nearby"
    case startingSoon = "Starting Soon"
    case ongoing = "Ongoing"
    case sponsored = "Sponsored"
}

struct EventJoins: Codable, Identifiable {
    var id: Int?
    var eventId: Int
    var userId: UUID
    var createdAt: Date?
    var isHost: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case userId = "user_id"
        case createdAt = "created_at"
        case isHost = "is_host"
    }
}

struct EventThumbnail: Transferable, Equatable {
    let image: Image
    let data: Data
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let image = EventThumbnail(data: data) else {
                throw TransferError.importFailed
            }
            
            return image
        }
    }
}

extension EventThumbnail {
    init?(data: Data) {
        guard let uiImage = UIImage(data: data) else {
            return nil
        }
        
        let image = Image(uiImage: uiImage)
        self.init(image: image, data: data)
    }
    
}

struct DropInEvent: Codable, Identifiable, Equatable {
    var id: Int?
    var createdAt: Date?
    var updatedAt: Date?
    var title: String
    var description: String
    var imagePaths: [String]
    var userId: UUID?
    var start: Date
    var end: Date
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var slotLimit: Int
    var slotsTaken: Int?
    var ageRestricted: Bool
    var chatEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case title
        case description
        case imagePaths = "image_paths"
        case userId = "user_id"
        case start
        case end
        case latitude
        case longitude
        case slotLimit = "slot_limit"
        case slotsTaken = "slots_taken"
        case ageRestricted = "age_restricted"
        case chatEnabled = "chat_enabled"
    }
}

extension DropInEvent: Hashable { }

struct OperationState {
    var isRunning = false
    var hasError = false
    var error: Error?
}

// - MARK: Error Types

enum TransferError: Error {
    case importFailed
}
