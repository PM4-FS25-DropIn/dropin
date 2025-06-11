//
//  DiscoveryEventListViewModel.swift
//  DropIn
//
//  Created by leo on 22.05.2025.
//

import SwiftUI


/// View model for managing and displaying a filtered list of discoverable DropIn events.
/// Handles category-based filtering, joining events, and feed refresh operations.
@MainActor
@Observable
final class DiscoveryEventListViewModel {
    
    /// All nearby events that are not yet joined by the user.
    var events: [DropInEvent] = []
    /// Currently selected category used to filter displayed events.
    var selectedEventCategory: EventCategory = .forYou
    
    /// Reference to the shared event store used to fetch and update event data.
    var eventStore: EventStore?
    
    /// Updates the local list of events by filtering out past events from the event store.
    func updateEvents() {
        guard let eventStore else { return }
        events = removePastEvents(eventStore.getNotJoinedEvents())
    }
    
    /// Clears existing events and loads a new batch of nearby events, removing expired ones.
    func refreshFeed() async throws {
        guard let eventStore else { return }
        try await eventStore.clearEvents()
        _ = try await eventStore.loadMoreNearbyEvents()
        events = removePastEvents(eventStore.getNotJoinedEvents())
    }
    
    /// Loads more events from the backend and updates the event list.
    func fetchAdditionalEvents() async throws {
        guard let eventStore else { return }
        
        _ = try await eventStore.loadMoreNearbyEvents()
        events = removePastEvents(eventStore.getNotJoinedEvents())
    }
    
    /// Joins the specified event and removes it from the current list.
    /// - Parameter event: The event to join.
    func joinEvent(_ event: DropInEvent) async throws {
        guard let eventStore else { return }
        _ =  try await eventStore.joinEvent(event)
        
        withAnimation {
            events.removeAll { $0.id == event.id }
        }
    }
    
    /// Filters and returns events that are currently ongoing.
    private func getLiveEvents(from events: [DropInEvent]) -> [DropInEvent] {
        let now = Date()
        return events.filter { event in
            event.start <= now && event.end >= now
        }
    }
    
    /// Filters and returns events that are starting within the next 30 minutes.
    private func getStartingSoonEvents(from events: [DropInEvent]) -> [DropInEvent] {
        let now = Date()
        let in30Minutes = now.addingTimeInterval(30 * 60)
        
        return events.filter { event in
            event.start > now && event.start <= in30Minutes
        }
    }
    
    /// Filters out events that have already ended.
    private func removePastEvents(_ events: [DropInEvent]) -> [DropInEvent] {
        return events.filter { event in
            return event.end > Date()
        }
    }
    
    /// Returns events based on the currently selected category.
    /// Supports .forYou, .ongoing, and .startingSoon filters.
    func getCategoryBasedEvents() -> [DropInEvent] {
        switch (selectedEventCategory) {
        case .forYou:
            return events
        case .ongoing:
            return getLiveEvents(from: events)
        case .startingSoon:
            return getStartingSoonEvents(from: events)
        }
    }
    
}
