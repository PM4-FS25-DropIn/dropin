//
//  Models.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

import Foundation
import CoreLocation

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

enum EventVisibility: String, CaseIterable, Codable {
    case `public`
    case friends
    case invite
}

enum EventStatus: String, CaseIterable, Codable {
    case upcoming
    case live
    case closing
}

struct DropInEvent: Identifiable, Codable {
    var id: Int
    var createdAt: Date?
    var title: String
    var description: String
    var imagePaths: [String]?
    var userId: UUID?
    var start: Date
    var end: Date
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var maxSlots: Int
    var takenSlots: Int
    var visibility: EventVisibility
    var ageRestricted: Bool
    var chatEnabled: Bool
    var status: EventStatus
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case title
        case description
        case imagePaths = "image_paths"
        case userId = "user_id"
        case start
        case end
        case latitude
        case longitude
        case maxSlots = "max_slots"
        case takenSlots = "taken_slots"
        case visibility
        case ageRestricted = "age_restricted"
        case chatEnabled = "chat_enabled"
        case status
    }
}
