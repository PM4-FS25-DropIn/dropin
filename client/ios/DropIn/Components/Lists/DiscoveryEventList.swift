//
//  DiscoveryEventList.swift
//  dropin
//
//  Created by Moritz Feuchter on 01/05/2025.
//


import SwiftUI

struct DiscoveryEventList: View {
    @Environment(EventStore.self) private var eventStore
    @State private var vm: DiscoveryEventListViewModel = DiscoveryEventListViewModel()
    
    var body: some View {
        Group {
            EventCategoryTabView(selectedCategory: $vm.selectedEventCategory)
                .padding(.horizontal)
                .padding(.vertical, 5)
            
            switch(vm.selectedEventCategory) {
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
        .onAppear {
            vm.eventStore = eventStore
        }
    }
    
    private func placeholder(text: String) -> some View {
        VStack {
            Text(text)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var eventList: some View {
        Group {
            if vm.events.isEmpty {
                noEventsFoundView
            } else {
                ScrollView {
                    LazyVStack(alignment: .center, spacing: 25) {
                        var _ = print("Discovery Events are \(vm.events.count)")
                        ForEach(vm.events) { event in
                            EventCard(event: event, joinEventAction: vm.joinEvent)
                                .onAppear {
                                    if event == vm.events.last {
                                        Task {
                                            print("Last. fetching new ones")
                                            try await vm.fetchNewEvents()
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
                        .animation(.easeInOut, value: vm.events)
                    }
                    .padding()
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    Task {
                        try await vm.refreshFeed()
                    }
                }
            }
        }
        .onAppear {
            vm.updateEvents()
        }
    }
    
    private var noEventsFoundView: some View {
        VStack {
            Spacer()
            Text("Womp womp...")
                .font(.headline)
                .bold()
            Text("We couldn't find any events near you.")
                .font(.subheadline)
                .bold()
                .foregroundStyle(.secondary)
            Button("Try again") {
                Task {
                    try await vm.refreshFeed()
                }
            }
            Spacer()
        }
    }
    
}

#Preview {
    DiscoveryEventList()
        .environment(EventStore())
}
