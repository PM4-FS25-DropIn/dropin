import SwiftUI
import PhotosUI
import Auth
import Storage

@MainActor
@Observable
class EventStore {
    
    /// All fetched events for feed and map display.
    var events: [DropInEvent] = []
    
    /// Events the user joined (including his own).
    var joinedEvents: [DropInEvent] = []
    
    var searchDelta: Double = 0
    
    private var userId: UUID?
    private var userLocation: CLLocationCoordinate2D?
    
    init() {
        Task {
            joinedEvents = try await fetchEventsJoinedByUser()
            //feedEvents = try await refreshEventsFeed()
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
    
    
    /// Refresh events feed.
    func refreshEventsFeed() async throws {
        var events: [DropInEvent] = try await searchEventsInRegion(latitude: userLocation?.latitude ?? 0, longitude: userLocation?.longitude ?? 0, latitudeDelta: searchDelta, longitudeDelta: searchDelta)

        
        // Fallback if user is located in devils ass crack.
        if events.isEmpty {
            print("Nothing found during refresh")
            events = try await supabase
                .from("events_not_joined")
                .select()
                .limit(10)
                .execute()
                .value
        }
        
        self.events = events
        searchDelta = 0
    }
    
    func getNotJoinedEvents() -> [DropInEvent] {
        /*let eventsJoined: [DropInEvent] = try await supabase
            .from("events_joined_by_user")
            .select()
            .execute()
            .value
         */
        
        //let joinedIds = Set(eventsJoined.compactMap((\.id)))
        let joinedIds = Set(joinedEvents.compactMap((\.id)))

        print("Joined ids are \(joinedIds)")
        
        // Return all events that have not the same id as in the eventsJoined array
        return events.filter { event in
            guard let id = event.id else { return false }
            return !joinedIds.contains(id)
        }
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
    
    /// Search and fetch events with an increasing searchDelta. A fallback is provided in case user location is disabled or unavailable.
    func loadMoreNearbyEvents() async throws {
        searchDelta += 0.25
        print("Search Delta is: \(searchDelta)")
        
        var events: [DropInEvent] = try await searchEventsInRegion(latitude: userLocation?.latitude ?? 0, longitude: userLocation?.longitude ?? 0, latitudeDelta: searchDelta, longitudeDelta: searchDelta)
        
        var filteredEvents = filterNewEvents(events, from: events)
        
        // Fallback if user is located in devils ass crack.
        if filteredEvents.isEmpty {
            print("Empty. Using fallback")
            events = try await supabase
                .from("events_not_joined")
                .select()
                .limit(10)
                .execute()
                .value
            filteredEvents = filterNewEvents(events, from: self.events)
            print("Filtered Events count is \(filteredEvents.count)")
        }
        
        events.append(contentsOf: filteredEvents)
        print("Now has \(events.count)")
    }
    
    /// Fetch events in current camera region.
    func fetchEventsInCameraRegion(latitude: Double, longitude: Double, latitudeDelta: Double, longitudeDelta: Double) async throws {
        let events: [DropInEvent] = try await searchEventsInRegion(latitude: latitude, longitude: longitude, latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        
        let filteredEvents = filterNewEvents(events, from: self.events)
        
        print("Filtered Events count \(filteredEvents.count)")
        self.events.append(contentsOf: filteredEvents)
        
        searchDelta = max(latitudeDelta, longitudeDelta)
    }
    
    
    /// Search and return events in a certain region (triggered by mapcamera movements).
    private func searchEventsInRegion(latitude: Double, longitude: Double, latitudeDelta: Double, longitudeDelta: Double) async throws -> [DropInEvent] {
        let events: [DropInEvent] = try await supabase
            .rpc("get_events_in_region", params: ["center_lat": latitude, "center_lon": longitude, "lat_delta": latitudeDelta, "lon_delta": longitudeDelta])
            .execute()
            .value
        
        print("Calling fetch Events in region")
        print("Now has: \(events.count)")
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
        
        var updatedEvent = event
        updatedEvent.slotsTaken! += 1
        joinedEvents.append(updatedEvent)
        
        if let index = events.firstIndex(where: { $0.id == updatedEvent.id }) {
            events[index] = updatedEvent
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
        
        var updatedEvent = event
        updatedEvent.slotsTaken! -= 1
        
        if let index = events.firstIndex(where: { $0.id == updatedEvent.id }) {
            events[index] = updatedEvent
        }
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
                    events.append(event)
                }
            } catch {
                try await deleteEvent(event)
                print("Couldn't convert or upload images.")
                throw EventStoreError.imageUploadFailed
            }
            
        } else {
            print("Add inserted event")
            joinedEvents.append(insertedEvent[0])
            events.append(insertedEvent[0])
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
        events.removeAll { $0.id == event.id }
        //feedEvents.removeAll { $0.id == event.id }
        //mapEvents.removeAll { $0.id == event.id }
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
    
    // Filter events already stored.
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

