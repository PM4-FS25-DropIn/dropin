//
//  Models.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

import Foundation
import CoreLocation


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

struct DropInEvent: Codable {
    var id: Int?
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
