//
//  EventService.swift
//  dropin-prototype
//
//  Created by leo on 31.03.2025.
//

import Foundation
import Auth

@MainActor
@Observable
class EventService {
    
    /// This function is used to retrieve the user object of the currently logged in
    /// - Returns: Supabase User Object
    /// - Throws: EventServiceError if user not logged in or not found
    private func getUser() async throws -> User {
        return try await supabase.auth.session.user
    }
    
    /// Fetches all events the user created
    func fetchEventsOfUser() async throws -> [DropInEvent] {
        let user = try await getUser()
        
        let events: [DropInEvent] = try await supabase
            .from("events")
            .select()
            .eq("user_id", value: user.id)
            .execute()
            .value
        
        return events
    }
    
    /// Fetches all events the user is officially attending  (including his own)
    func fetchAttendingEventsOfUser() async throws -> [DropInEvent] {
        let events: [DropInEvent] = try await supabase
            .from("events_joined_by_user")
            .select()
            .execute()
            .value
        
        return events
    }
    
    /// Fetches up to 5 events from the events_not_responded_to table that are not in the excludedIDs list.
    func fetchEventsFeed(excludingIDs: Set<Int> = []) async throws -> [DropInEvent] {
        let events: [DropInEvent] = try await supabase
            .rpc("fetch_events_feed", params: ["excluded_ids": [excludingIDs]])
            .execute()
            .value
        
        return events
    }
    
    /// Join a specific event
    func joinEvent(_ event: DropInEvent) async throws {
        let user = try await getUser()
        
        guard let eventId = event.id else {
            throw EventServiceError.eventIdNotValid
        }
        
        try await supabase
            .from("event_joins")
            .upsert(EventJoins(eventId: eventId, userId: user.id))
            .execute()
    }
    
    /// Leave a specific event
    /// This will remove the row from the event_joins table
    func leaveEvent(_ event: DropInEvent) async throws {
        let user = try await getUser()
        
        guard let eventId = event.id else {
            throw EventServiceError.eventIdNotValid
        }
        
        try await supabase
            .from("event_joins")
            .delete()
            .eq("event_id", value: eventId)
            .eq("user_id", value: user.id)
            .execute()
    }
    
    /// Decline a specific event
    /// This will insert a row in the event_declines
    func declineEvent(_ event: DropInEvent) async throws {
        let user = try await getUser()
        
        guard let eventId = event.id else {
            throw EventServiceError.eventIdNotValid
        }
        
        try await supabase
            .from("event_declines")
            .insert(EventDeclines(eventId: eventId, userId: user.id))
            .execute()
    }
    
    /// Create a new event
    func createEvent(_ event: DropInEvent) async throws {
        let user = try await getUser()
        
        var event = event
        event.userId = user.id
        
        try await supabase
            .from("events")
            .insert(event)
            .execute()
    }
    
    /// Delete an event
    func deleteEvent(_ event: DropInEvent) async throws {
        try await supabase
            .from("events")
            .delete()
            .eq("id", value: event.id)
            .execute()
    }
    
    /// Update an event
    func updateEvent(_ event: DropInEvent) async throws {
        try await supabase
            .from("events")
            .update(event)
            .eq("id", value: event.id)
            .execute()
    }
    
    
    func getHostUsername(of event: DropInEvent) async throws -> String {
        let profile: [Profile] = try await supabase
            .from("profiles")
            .select()
            .eq("id", value: event.userId)
            .limit(1)
            .execute()
            .value
        
        guard let username = profile.first?.username else {
            throw EventServiceError.eventNotFound
        }
        
        return username
    }
    
}

enum EventServiceError: Error {
    case eventNotFound
    case eventIdNotValid
}
