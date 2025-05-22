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
    
    var searchDelta: Double = 0.25
    
    private var userId: UUID?
    private var userLocation: CLLocationCoordinate2D?
    
    init() {
        Task {
            joinedEvents = try await fetchEventsJoinedByUser()
            feedEvents = try await refreshEventsFeed()
            userId = try await getUserId()
            userLocation = LocationService.shared.lastLocation.coordinate
            print("Initialized EventStore with userId: \(userId?.debugDescription ?? "nil")")
        }
    }
    
    private func getUserId() async throws -> UUID {
        return try await supabase.auth.session.user.id
    }
    
    
    private func fetchEventsJoinedByUser() async throws -> [DropInEvent] {
        try await supabase.rpc("get_joined_events_of_user")
            .execute()
            .value
    }
    
    
    /// Initial fetch of nearby events around user position.
    func refreshEventsFeed() async throws -> [DropInEvent] {
        return try await fetchEventsInRegion(latitude: userLocation?.latitude ?? 0, longitude: userLocation?.longitude ?? 0, latitudeDelta: searchDelta, longitudeDelta: searchDelta)
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
    
    /// Check if an event has been joined by the current user.
    func checkIfEventIsJoinedByUser(_ event: DropInEvent) -> Bool {
        guard let eventId = event.id, let eventUserId = event.userId else { return false }
        
        for event in joinedEvents {
            guard let joinedEventId = event.id, let joinedEventUserId = event.userId else { continue }
            if eventId == joinedEventId && eventUserId == joinedEventUserId {
                return true
            }
        }
        return false
    }
    
    /// Fetch additional events by increasing searchDelta and find events further away from the user.
    func fetchEventsFeed() async throws {
        searchDelta += 0.25
        
        var events: [DropInEvent] = try await fetchEventsInRegion(latitude: userLocation?.latitude ?? 0, longitude: userLocation?.longitude ?? 0, latitudeDelta: searchDelta, longitudeDelta: searchDelta)
        
        var filteredEvents = filterNewEvents(events, from: feedEvents)
        
        // Fallback if user is located in devils ass crack.
        if filteredEvents.isEmpty {
            events = try await supabase
                .from("events")
                .select()
                .limit(10)
                .execute()
                .value
            filteredEvents = filterNewEvents(events, from: feedEvents)
        }
        
        feedEvents.append(contentsOf: filteredEvents)
        
        print("Calling fetch more feed events")
        print("Now has \(feedEvents.count)")
    }
    
    func fetchMapEvents(latitude: Double, longitude: Double, latitudeDelta: Double, longitudeDelta: Double) async throws {
        let events: [DropInEvent] = try await fetchEventsInRegion(latitude: latitude, longitude: longitude, latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        mapEvents = events
    }
    
    
    /// Fetch events in a certain region (triggered by mapcamera movements).
    func fetchEventsInRegion(latitude: Double, longitude: Double, latitudeDelta: Double, longitudeDelta: Double) async throws -> [DropInEvent] {
        let events: [DropInEvent] = try await supabase
            .rpc("get_events_in_region", params: ["center_lat": latitude, "center_lon": longitude, "lat_delta": latitudeDelta, "lon_delta": longitudeDelta])
            .execute()
            .value
        
        print("Calling fetch Events in region")
        print("Now has: \(mapEvents.count)")
        return events
    }
    
    
    /// Join a specific event.
    func joinEvent(_ event: DropInEvent) async throws -> DropInEvent {
        
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
        
        var updatedEvent = event
        updatedEvent.slotsTaken! += 1
        joinedEvents.append(updatedEvent)
        
        // Update map event
        if let index = mapEvents.firstIndex(where: { $0.id == updatedEvent.id }) {
            mapEvents[index] = updatedEvent
        }
        
        return updatedEvent
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
        
        let insertedEvent: [DropInEvent] = try await supabase
            .rpc("insert_event", params: ["event": event])
            .execute()
            .value
        
        if !photos.isEmpty {
            var event = insertedEvent[0]
            var imagePaths: [String] = []
            
            do {
                if let eventId = event.id {
                    let eventThumbnails = try await convertPhotoSelectionToEventThumbnail(photos)
                    imagePaths = try await uploadEventThumbnailPhotos(eventId: eventId, photos: eventThumbnails)
                    event.imagePaths = imagePaths
                    
                    try await updateEvent(event)
                    joinedEvents.append(event)
                    mapEvents.append(event)
                }
            } catch {
                try await deleteEvent(event)
                print("Couldn't convert or upload images.")
                throw EventStoreError.imageUploadFailed
            }
            
        } else {
            print("Add inserted event")
            joinedEvents.append(insertedEvent[0])
            mapEvents.append(insertedEvent[0])
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
            .rpc("update_event", params: ["event": event])
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
    case imageUploadFailed
}

