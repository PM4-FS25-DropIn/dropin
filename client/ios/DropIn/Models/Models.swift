import Foundation
import CoreLocation
import SwiftUI

/// Represents a user profile within the DropIn app.
struct Profile: Codable, Identifiable {
    /// Unique identifier for the profile.
    let id: UUID
    /// The public username of the user.
    let username: String
    /// URL string of the user's avatar image.
    let avatarUrl: String?
    /// URL string of the user's banner image.
    let bannerUrl: String?
    /// Optional emoji string.
    let emojicode: String?
    /// City of the user.
    let city: String?
    /// Number of events the user has created.
    let dropinsCreated: Int?
    /// Number of events the user joined.
    let dropinsJoined: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case avatarUrl = "avatar_url"
        case bannerUrl = "banner_url"
        case emojicode
        case city
        case dropinsCreated = "dropins_created"
        case dropinsJoined = "dropins_joined"
    }
}

/// Represents a message in the chats.
struct Message: Identifiable, Equatable {
    /// Unique identifier for the message.
    let id: UUID = UUID()
    /// Unique id of the corresponding chat room.
    let chatRoomId: Int
    /// Username of the author of this message.
    let username: String
    /// Content of the message.
    let content: String
    /// Shows if session is current.
    let isCurrentSession: Bool
    /// Timestamp of the message.
    let timestamp: Date
    
    /// Message date formatter.
    static let formatter = DateFormatter()
    
    /// Returns the formatted timestamp.
    func formattedTimestamp() -> String {
        Self.formatter.dateStyle = .none
        Self.formatter.timeStyle = .short
        return Self.formatter.string(from: timestamp)
    }
    
    /// Returns the formatted date.
    func formattedDate() -> String {
        Self.formatter.dateStyle = .medium
        Self.formatter.timeStyle = .none
        return Self.formatter.string(from: timestamp)
    }
}

/// Represents the data transfer object of a message.
struct MessageDTO: Codable {
    /// The id of the sender.
    let sender_id: UUID
    /// The name of the session.
    let session_name: String
    /// The content of the message.
    let content: String
    /// The creation date of the message.
    let created_at: Date
    /// The unique identifier of the chatroom.
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

/// Represents a chatroom.
struct ChatRoom: Identifiable {
    /// The id of the chatroom.
    let id: UUID
    /// The id of an event.
    let eventId: UUID
    /// The creation date of the chatroom.
    let createdAt: Date
}

/// Represents the categories for the EventCategoryTabView.
enum EventCategory: String, CaseIterable {
    case forYou = "For You"
    case ongoing = "Ongoing"
    case startingSoon = "Starting Soon"
}

/// Represents an entry for an event join.
struct EventJoins: Codable, Identifiable {
    /// Unique identifier for an event join.
    var id: Int?
    /// The id of the joined event.
    var eventId: Int
    /// The user id of the user joining this event.
    var userId: UUID
    /// The date of joining an event.
    var createdAt: Date?
    /// Shows if the user is the host of this event.
    var isHost: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case userId = "user_id"
        case createdAt = "created_at"
        case isHost = "is_host"
    }
}

/// Represents an event thumbnail.
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

/// Represents an avatar image.
struct AvatarImage: Transferable, Equatable {
    let image: Image
    let data: Data
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let image = AvatarImage(data: data) else {
                throw TransferError.importFailed
            }
            
            return image
        }
    }
}

extension AvatarImage {
    init?(data: Data) {
        guard let uiImage = UIImage(data: data) else {
            return nil
        }
        
        let image = Image(uiImage: uiImage)
        self.init(image: image, data: data)
    }
    
}

/// Represents a banner image.
struct BannerImage: Transferable, Equatable {
    let image: Image
    let data: Data
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let image = BannerImage(data: data) else {
                throw TransferError.importFailed
            }
            
            return image
        }
    }
}

extension BannerImage {
    init?(data: Data) {
        guard let uiImage = UIImage(data: data) else {
            return nil
        }
        
        let image = Image(uiImage: uiImage)
        self.init(image: image, data: data)
    }
    
}

/// Represents an event.
struct DropInEvent: Codable, Identifiable, Equatable {
    /// Unique identifier of an event.
    var id: Int?
    /// Creation date of an event.
    var createdAt: Date?
    /// The date of an update of an event.
    var updatedAt: Date?
    /// The title of an event.
    var title: String
    /// A description of an event.
    var description: String
    /// URLs of event thumbnails.
    var imagePaths: [String]?
    /// UserId of the creating user.
    var userId: UUID?
    /// Start date of the event.
    var start: Date
    /// End date of the event.
    var end: Date
    /// Maximum participants of an event.
    var slotLimit: Int
    /// Current participant counts of an event.
    var slotsTaken: Int?
    /// Age restriction policy of this event.
    var ageRestricted: Bool
    /// Chat enable status of this event.
    var chatEnabled: Bool
    
    /// Location of this event.
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

/// Represents a coordinate.
struct GeoJSONPoint: Codable, Equatable, Hashable {
    var type: String = "Point"
    var coordinates: [Double]
}

/// Represents an operation state of an async task.
struct OperationState {
    var isRunning = false
    var hasError = false
    var error: Error?
}

/// Represents authentication modes.
enum AuthMode {
    case signIn
    case signUp
}

/// Represents a way to store credentials.
struct AuthCredentials {
    var username: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
}

// - MARK: Error Types

enum TransferError: Error {
    case importFailed
}
