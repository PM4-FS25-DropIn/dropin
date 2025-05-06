import SwiftUI
import PhotosUI
import Auth
import Storage

@MainActor
@Observable
class EventStore {
    
    /// Events to display on home view.
    var feedEvents: [DropInEvent] = []
    
    /// Events to display on the map.
    var mapEvents: [DropInEvent] = []
    
    /// Events the user joined (including his own).
    var joinedEvents: [DropInEvent] = []
    
    private var userId: UUID?
    
    init() {
        Task {
            feedEvents = try await fetchInitialEventsFeed()
            joinedEvents = try await fetchInitialAttendingEventsOfUser()
            mapEvents = try await fetchInitialMapEvents()
            userId = try await getUserId()
            print("Initialized EventStore with userId: \(userId?.debugDescription ?? "nil")")
        }
    }
    
    private func getUserId() async throws -> UUID {
        return try await supabase.auth.session.user.id
    }
    
    /// Initial fetch of attending events of the user (including the user created events).
    private func fetchInitialAttendingEventsOfUser() async throws -> [DropInEvent] {
        let events: [DropInEvent] = try await supabase
            .from("events_joined_by_user")
            .select()
            .execute()
            .value
        
        return events
    }
    
    /// Initial fetch of 5 events the user has not joined yet.
    // TODO: Initial fetch should fetch events nearby.
    private func fetchInitialEventsFeed() async throws -> [DropInEvent] {
        let events: [DropInEvent] = try await supabase
            .from("events_not_joined")
            .select()
            .limit(5)
            .execute()
            .value
        
        return events
    }
    
    // TODO: Fetch events nearby.
    private func fetchInitialMapEvents() async throws -> [DropInEvent] {
        let events: [DropInEvent] = try await supabase
            .from("events")
            .select()
            .limit(10)
            .execute()
            .value
        
        return events
    }
    
    
    /// Fetch events created by the user.
    func fetchEventsOfUser() -> [DropInEvent] {
        var events: [DropInEvent] = []
        
        for event in joinedEvents {
            guard let eventUserId = event.userId else { continue }
            if eventUserId == userId {
                events.append(event)
            }
        }
        return events
    }
    
    /// Fetch more events that haven't been fetched yet.
    //TODO: Might be broken with the excluded ids fetching. Logic should be already in here.
    func fetchMoreFeedEvents() async throws {
        let alreadyFetchedEventsIds = Set(feedEvents.compactMap(\.id))
        
        let events: [DropInEvent] = try await supabase
            .rpc("fetch_events_feed", params: ["excluded_ids": [alreadyFetchedEventsIds]])
            .execute()
            .value
        
        let filteredEvents = filterNewEvents(events, from: feedEvents)
        
        feedEvents.append(contentsOf: filteredEvents)
        
        print("Calling fetch more feed events")
        print("Now has \(feedEvents.count)")
    }
    
    // Fresh new fetch of events for the homeview.
    func refreshFeedEvents() async throws {
        let events: [DropInEvent] = try await supabase
            .from("events_not_joined")
            .select()
            .limit(10)
            .execute()
            .value
        
        feedEvents = events
    }
    
    /// Fetch events in a certain region (triggered by map movements).
    // TODO: Implement fetching events in region.
    func fetchEventsInRegion(latitude: Double, longitude: Double, latitudeDelta: Double, longitudeDelta: Double) async throws {
        
        let events: [DropInEvent] = try await supabase
            .from("events")
            .select()
            .limit(5)
            .execute()
            .value
        
        mapEvents.append(contentsOf: filterNewEvents(events, from: mapEvents))
        print("Calling fetch Events in region")
        print("Now has: \(feedEvents.count)")
    }
    
    
    /// Join a specific event.
    func joinEvent(_ event: DropInEvent) async throws {
        
        guard let eventId = event.id else {
            throw EventStoreError.eventIdNotValid
        }
        
        guard let userId else {
            throw EventStoreError.userIdNotFound
        }
        
        try await supabase
            .from("event_joins")
            .upsert(EventJoins(eventId: eventId, userId: userId))
            .execute()
        
        withAnimation {
            feedEvents.removeAll { $0.id == eventId }
        }
        joinedEvents.append(event)
    }
    
    /// Leave a specific event.
    /// This will remove the row from the event_joins table.
    func leaveEvent(_ event: DropInEvent) async throws {
        try await supabase
            .from("event_joins")
            .delete()
            .eq("event_id", value: event.id)
            .eq("user_id", value: userId)
            .execute()
        
        joinedEvents.removeAll { $0.id == event.id }
    }
    
    /// Create a new event.
    func createEvent(_ event: DropInEvent, photos: [PhotosPickerItem]) async throws {
        
        let insertedEvents: [DropInEvent] = try await supabase
            .from("events")
            .insert(event)
            .select()
            .execute()
            .value
        
        
        if !photos.isEmpty {
            var event = insertedEvents[0]
            var imagePaths: [String] = []
            
            do {
                if let eventId = event.id {
                    let eventThumbnails = try await convertPhotoSelectionToEventThumbnail(photos)
                    imagePaths = try await uploadEventThumbnailPhotos(eventId: eventId, photos: eventThumbnails)
                    event.imagePaths = imagePaths
                    print("Path is: \(imagePaths[0])")
                    
                    try await updateEvent(event)
                    joinedEvents.append(contentsOf: insertedEvents)
                    mapEvents.append(contentsOf: insertedEvents)
                }
            } catch {
                try await deleteEvent(event)
                print("Couldn't convert or upload images.")
            }
            
        } else {
            joinedEvents.append(contentsOf: insertedEvents)
            mapEvents.append(contentsOf: insertedEvents)
        }
    }
    
    /// Delete an event.
    func deleteEvent(_ event: DropInEvent) async throws {
        print("Deleting event with id: \(event.id ?? 0)")
        try await supabase
            .from("events")
            .delete()
            .eq("id", value: event.id)
            .execute()
        
        joinedEvents.removeAll { $0.id == event.id }
        feedEvents.removeAll { $0.id == event.id }
        mapEvents.removeAll { $0.id == event.id }
    }
    
    /// Update an event.
    func updateEvent(_ event: DropInEvent) async throws {
        try await supabase
            .from("events")
            .update(event)
            .eq("id", value: event.id)
            .execute()
        
        if let index = joinedEvents.firstIndex(where: { $0.id == event.id }) {
            joinedEvents[index] = event
        }
    }
    
    private func uploadEventThumbnailPhotos(eventId: Int, photos: [EventThumbnail]) async throws -> [String] {
        
        var publicFileUrlPath: [String] = []
        
        for photo in photos {
            let fileName = UUID().uuidString
            print("Uploading photo")
            try await supabase.storage
                .from("event-thumbnails")
                .upload(
                    "\(eventId)/\(fileName)",
                    data: photo.data,
                    options: FileOptions(contentType: "image/jpeg", upsert: false)
                )
            let publicFileUrl = try supabase.storage
                .from("event-thumbnails")
                .getPublicURL(path: "\(eventId)/\(fileName)")
            
            publicFileUrlPath.append(publicFileUrl.absoluteString)
        }
        print("File url: \(publicFileUrlPath[0])")
        
        return publicFileUrlPath
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
            throw EventStoreError.eventNotFound
        }
        
        return username
    }
    
    func getAttendanceStatus(of eventId: Int) -> AttendanceStatus {
        return joinedEvents.contains(where: { $0.id == eventId }) ? .joined : .undetermined
    }
    
    private func filterNewEvents(_ incoming: [DropInEvent], from existing: [DropInEvent]) -> [DropInEvent] {
        let existingIds = Set(existing.compactMap(\.id))
        return incoming.filter { event in
            guard let id = event.id else { return false }
            return !existingIds.contains(id)
        }
    }
}

enum EventStoreError: Error {
    case eventNotFound
    case eventIdNotValid
    case userIdNotFound
}

