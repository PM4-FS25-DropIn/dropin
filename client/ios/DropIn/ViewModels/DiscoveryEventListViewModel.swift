//
//  DiscoveryEventListViewModel.swift
//  DropIn
//
//  Created by leo on 22.05.2025.
//

import SwiftUI


@MainActor
@Observable
final class DiscoveryEventListViewModel {
    
    var events: [DropInEvent] = []
    var selectedEventCategory: EventCategory = .forYou
    
    var eventStore: EventStore?
    
    func updateEvents() {
        guard let eventStore else { return }
        events = removePastEvents(eventStore.getNotJoinedEvents())
    }
    
    func refreshFeed() async throws {
        guard let eventStore else { return }
        try await eventStore.clearEvents()
        _ = try await eventStore.loadMoreNearbyEvents()
        events = removePastEvents(eventStore.getNotJoinedEvents())
    }
    
    func fetchAdditionalEvents() async throws {
        guard let eventStore else { return }
        
        _ = try await eventStore.loadMoreNearbyEvents()
        events = removePastEvents(eventStore.getNotJoinedEvents())
    }
    
    func joinEvent(_ event: DropInEvent) async throws {
        guard let eventStore else { return }
        _ =  try await eventStore.joinEvent(event)
        
        withAnimation {
            events.removeAll { $0.id == event.id }
        }
    }
    
    private func getLiveEvents(from events: [DropInEvent]) -> [DropInEvent] {
        let now = Date()
        return events.filter { event in
            event.start <= now && event.end >= now
        }
    }
    
    private func getStartingSoonEvents(from events: [DropInEvent]) -> [DropInEvent] {
        let now = Date()
        let in30Minutes = now.addingTimeInterval(30 * 60)
        
        return events.filter { event in
            event.start > now && event.start <= in30Minutes
        }
    }
    
    private func removePastEvents(_ events: [DropInEvent]) -> [DropInEvent] {
        return events.filter { event in
            return event.end > Date()
        }
    }
    
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
