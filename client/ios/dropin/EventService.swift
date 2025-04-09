//
//  EventService.swift
//  dropin-prototype
//
//  Created by leo on 31.03.2025.
//

import Foundation

@MainActor
@Observable
class EventService {
    /*
     1. Fetch all events from a user
     2. Get events from the db that user hasn't dropped in yet + hasn't declined
     3. Let a user create a new event
     4. Let a user update his own events
     */
    
    /// This function is used to retrieve the user object of the currently logged in
    /// - Returns: Supabase User Object
    /// - Throws: EventServiceError if user not logged in or not found
    private func getUser() async throws -> User {
        return try await supabase.auth.session.user
    }
    
    func fetchEventsOfUser() async throws -> [DropInEvent] {
        let user = try await getUser()
        
        let events: [DropInEvent] = try await supabase
            .from("dropins")
            .select()
            .eq("user_id", value: user.id)
            .execute()
            .value
        
        return events
    }
    
    func fetchEventsFeed() async throws -> [DropInEvent] {
        let events: [DropInEvent] = try await supabase
            .from("dropins")
            .select()
            .limit(10)
            .execute()
            .value
        return events
    }
    
    func createEvent(_ event: DropInEvent) async throws {
        let user = try await getUser()
        
        var event = event
        event.userId = user.id
        
        try await supabase
            .from("dropins")
            .insert(event)
            .execute()
    }
    
    func deleteEvent(_ event: DropInEvent) async throws {
        try await supabase
            .from("dropins")
            .delete()
            .eq("id", value: event.id)
            .execute()
    }
    
    func updateEvent(_ event: DropInEvent) async throws {
        try await supabase
            .from("dropins")
            .update(event)
            .eq("id", value: event.id)
            .execute()
    }
    
    func getOrganizerUsername(of event: DropInEvent) async throws -> String {
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
}
