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
    
    init() {
        print("New DiscoveryEventListViewModel")
    }
    
    func updateEvents() {
        guard let eventStore else { return }
        events = eventStore.getNotJoinedEvents()
    }
    
    func refreshFeed() async throws {
        guard let eventStore else { return }
        try await eventStore.refreshEventsFeed()
        events = eventStore.getNotJoinedEvents()
    }
    
    
    func fetchAdditionalEvents() async throws {
        guard let eventStore else { return }
        try await eventStore.loadMoreNearbyEvents()
        events = eventStore.getNotJoinedEvents()
    }
    
    func joinEvent(_ event: DropInEvent) async throws {
        guard let eventStore else { return }
        _ =  try await eventStore.joinEvent(event)
        
        withAnimation {
            events.removeAll { $0.id == event.id }
        }
    }
    
}
