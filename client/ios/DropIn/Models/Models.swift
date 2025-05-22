import Foundation
import CoreLocation
import SwiftUI

struct Profile: Codable {
    let id: UUID
    let username: String
    let avatarUrl: String?
    let emojicode: String?
    let city: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case avatarUrl = "avatar_url"
        case emojicode
        case city
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
    var slotLimit: Int
    var slotsTaken: Int?
    var ageRestricted: Bool
    var chatEnabled: Bool
    var location: GeoJSONPoint
    
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
        case slotLimit = "slot_limit"
        case slotsTaken = "slots_taken"
        case ageRestricted = "age_restricted"
        case chatEnabled = "chat_enabled"
        case location
    }
}

extension DropInEvent: Hashable {
    var latitude: CLLocationDegrees { location.coordinates[1] }
    var longitude: CLLocationDegrees { location.coordinates[0] }
}

struct GeoJSONPoint: Codable, Equatable, Hashable {
    var type: String = "Point"
    var coordinates: [Double]
}

struct OperationState {
    var isRunning = false
    var hasError = false
    var error: Error?
}

enum AuthMode {
    case signIn
    case signUp
}

// - MARK: Error Types

enum TransferError: Error {
    case importFailed
}

