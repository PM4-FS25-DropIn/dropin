import SwiftUI
import PhotosUI
import Auth
import Storage

/// A central service for managing DropIn events, including fetching, creating,
/// joining, leaving, updating, and deleting events, as well as handling user participation.
@MainActor
@Observable
class EventStore {
    
    /// All fetched events for feed and map display.
    var events: [DropInEvent] = []
    
    /// Indicates whether the store has completed initial setup.
    var isInitialized = false
    
    /// Events the user joined (including their own).
    var joinedEvents: [DropInEvent] = []
    
    /// Current delta used for event search expansion on the map.
    var searchDelta: Double = 0
    
    private var userId: UUID?
    private var userLocation: CLLocationCoordinate2D?
    
    /// Initializes the store by updating joined events and loading user data.
    init() {
        Task {
            try await updateJoinedEvents()
            userId = try await getUserId()
            userLocation = LocationService.shared.lastLocation.coordinate
            isInitialized = true
        }
    }
    
    /// Retrieves the currently authenticated user's ID.
    private func getUserId() async throws -> UUID {
        return try await supabase.auth.session.user.id
    }
    
    
    /// Fetches the list of events the user has joined from the backend.
    func updateJoinedEvents() async throws {
        joinedEvents = try await supabase
            .from("events_joined_by_user")
            .select()
            .execute()
            .value
        
        pruneExpiredJoinedEvents()
    }
    
    /// Removes joined events that have already ended.
    func pruneExpiredJoinedEvents() {
        joinedEvents.removeAll { event in
            return event.end < .now
        }
    }
    
    /// Clears all currently stored events and resets the search delta.
    func clearEvents() async throws {
        self.events = []
        searchDelta = 0
    }
    
    /// Returns a list of events that the user has not joined.
    func getNotJoinedEvents() -> [DropInEvent] {
        let joinedIds = Set(joinedEvents.compactMap((\.id)))

        pruneExpiredJoinedEvents()
        // Return all events that have not the same id as in the eventsJoined array
        return events.filter { event in
            guard let id = event.id else { return false }
            return !joinedIds.contains(id)
        }
    }
    
    
    /// Checks if a specific event has been joined by the current user.
    func checkIfEventIsJoinedByUser(_ event: DropInEvent) -> Bool {
        guard let eventId = event.id, let eventUserId = event.userId else { return false }
        
        pruneExpiredJoinedEvents()
        for event in joinedEvents {
            guard let joinedEventId = event.id, let joinedEventUserId = event.userId else { continue }
            if eventId == joinedEventId && eventUserId == joinedEventUserId {
                return true
            }
        }
        return false
    }
    
    /// Increases the search radius and fetches additional nearby events.
    func loadMoreNearbyEvents() async throws -> [DropInEvent] {
        searchDelta += 0.25
        print("Search Delta is: \(searchDelta)")
        
        let events: [DropInEvent] = try await searchEventsInRegion(latitude: userLocation?.latitude ?? 0, longitude: userLocation?.longitude ?? 0, latitudeDelta: searchDelta, longitudeDelta: searchDelta)
        
        let filteredEvents = filterNewEvents(events, from: self.events)
        
        self.events.append(contentsOf: filteredEvents)
        return filteredEvents
    }
    
    /// Fetches events within the visible region of the map camera.
    func fetchEventsInCameraRegion(latitude: Double, longitude: Double, latitudeDelta: Double, longitudeDelta: Double) async throws {
        let events: [DropInEvent] = try await searchEventsInRegion(latitude: latitude, longitude: longitude, latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        
        let filteredEvents = filterNewEvents(events, from: self.events)
        
        self.events.append(contentsOf: filteredEvents)
        
        searchDelta = max(latitudeDelta, longitudeDelta)
    }
    
    
    /// Executes a Supabase RPC to retrieve events in a specified geographical region.
    private func searchEventsInRegion(latitude: Double, longitude: Double, latitudeDelta: Double, longitudeDelta: Double) async throws -> [DropInEvent] {
        let events: [DropInEvent] = try await supabase
            .rpc("get_events_in_region", params: ["center_lat": latitude, "center_lon": longitude, "lat_delta": latitudeDelta, "lon_delta": longitudeDelta])
            .execute()
            .value
        
        return events
    }
    
    
    /// Joins the specified event and updates local state accordingly.
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
    
    /// Leaves the specified event and removes the join from the backend.
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
    
    /// Creates a new event, uploads any provided photos, and updates local state.
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
    
    private func convertPhotoSelectionToEventThumbnail(_ photos: [PhotosPickerItem]) async throws -> [EventThumbnail] {
        var eventThumbnails: [EventThumbnail] = []
        
        for photo in photos {
            guard let eventThumbnail = try await photo.loadTransferable(type: EventThumbnail.self) else {
                continue
            }
            eventThumbnails.append(eventThumbnail)
        }
        
        return eventThumbnails
    }
    
    /// Deletes an event from the backend and local store.
    func deleteEvent(_ event: DropInEvent) async throws {
        guard let eventId = event.id else { return }
        print("Deleting event with id: \(eventId)")
        try await supabase
            .from("events")
            .delete()
            .eq("id", value: eventId)
            .execute()
        
        joinedEvents.removeAll { $0.id == eventId }
        events.removeAll { $0.id == eventId }
    }
    
    /// Updates an existing event in the backend and local cache.
    func updateEvent(_ event: DropInEvent) async throws {
        try await supabase
            .rpc("update_event", params: ["event": event])
            .execute()
        
        if let index = joinedEvents.firstIndex(where: { $0.id == event.id }) {
            joinedEvents[index] = event
        }
    }
    
    /// Uploads thumbnail photos for an event and returns their public URLs.
    private func uploadEventThumbnailPhotos(eventId: Int, photos: [EventThumbnail]) async throws -> [String] {
        
        var publicFileUrlPaths: [String] = []
        
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
            
            publicFileUrlPaths.append(publicFileUrl.absoluteString)
        }
        print("File url: \(publicFileUrlPaths[0])")
        
        return publicFileUrlPaths
    }

    
    /// Fetches the username of the event host based on their user ID.
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
    
    /// Returns the attendance status (joined or not) of a specific event.
    func getAttendanceStatus(of eventId: Int) -> AttendanceStatus {
        return joinedEvents.contains(where: { $0.id == eventId }) ? .joined : .undetermined
    }
    
    /// Filters out already-stored events from the incoming event list.
    private func filterNewEvents(_ incoming: [DropInEvent], from existing: [DropInEvent]) -> [DropInEvent] {
        let existingIds = Set(existing.compactMap(\.id))
        return incoming.filter { event in
            guard let id = event.id else { return false }
            return !existingIds.contains(id)
        }
    }
    
    /// Retrieves the profiles of all participants in a given event.
    func getAllParticipants(of eventId: Int) async throws -> [Profile] {
        let eventJoins: [EventJoins] = try await supabase
            .from("event_joins")
            .select()
            .eq("event_id", value: eventId)
            .execute()
            .value
        
        print("Current EventJoins:",eventJoins)
        
        let userIds = eventJoins.map { $0.userId }
        
        print("Current userIds:",userIds)
        
        let profiles: [Profile] = try await supabase
            .from("profiles")
            .select()
            .in("id", values: userIds)
            .execute()
            .value
        
        return profiles
    }
}

enum EventStoreError: Error {
    case eventNotFound
    case eventIdNotValid
    case userIdNotFound
    case imageUploadFailed
}
