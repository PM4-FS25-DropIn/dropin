//
//  DiscoveryEventList.swift
//  dropin
//
//  Created by Moritz Feuchter on 01/05/2025.
//


import SwiftUI

struct DiscoveryEventList: View {
    @Environment(EventStore.self) private var eventStore
    @State private var selectedEventCategory: EventCategory = .forYou
    
    var body: some View {
        EventCategoryTabView(selectedCategory: $selectedEventCategory)
            .padding(.horizontal)
            .padding(.vertical, 5)
        
        switch(selectedEventCategory) {
        case .forYou:
            eventList
        case .nearby:
            placeholder(text: "Nearby")
        case .ongoing:
            placeholder(text: "Ongoing")
        case .sponsored:
            placeholder(text: "Sponsored")
        case .startingSoon:
            placeholder(text: "Starting Soon")
        case .trending:
            placeholder(text: "Trending")
        }
    }
    
    private func placeholder(text: String) -> some View {
        VStack {
            Text(text)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var eventList: some View {
        ScrollView {
            LazyVStack(alignment: .center, spacing: 25) {
                ForEach(eventStore.feedEvents, id: \.self) { event in
                    EventCard(event: event)
                        .onAppear {
                            if event == eventStore.feedEvents.last {
                                Task {
                                    fetchNewEvents()
                                }
                            }
                        }
                        .transition(
                            .asymmetric(
                                insertion: .opacity,
                                removal: .scale(scale: 0.9).combined(with: .opacity)
                            )
                        )
                }
                .animation(.easeInOut, value: eventStore.feedEvents)
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .refreshable {
            refreshFeed()
        }
    }
    
    private func refreshFeed() {
        Task {
            try await eventStore.refreshFeedEvents()
        }
    }
    
    
    // TODO: Maybe no async needed?
    private func fetchNewEvents() {
        Task {
            try await eventStore.fetchMoreFeedEvents()
        }
    }
}

#Preview {
    DiscoveryEventList()
        .environment(EventStore())
}
