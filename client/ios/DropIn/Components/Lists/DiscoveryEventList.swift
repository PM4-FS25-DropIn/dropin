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
    @State private var fetchEventsStatus: AsyncStatus = .idle
    
    var body: some View {
        Group {
            EventCategoryTabView(selectedCategory: $vm.selectedEventCategory)
                .padding(.horizontal)
                .padding(.vertical, 5)
            
            if fetchEventsStatus.isRunning {
                searchingEventsProgressView
            } else {
                eventList
            }
        }
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
                                    if event == vm.events.last && vm.events.count != 1 {
                                        fetchAdditionalEvents()
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
                    refreshFeed()
                }
            }
        }
        .onAppear {
            vm.eventStore = eventStore
            if eventStore.isInitialized {
                vm.updateEvents()
            } else {
                Task {
                    while !eventStore.isInitialized {
                        try? await Task.sleep(nanoseconds: 100_000_000)
                    }
                    vm.updateEvents()
                }
            }
        }
    }
    
    private var noEventsFoundView: some View {
        VStack(alignment: .center, spacing: 15) {
            Spacer()
            Text("Womp womp...")
                .font(.headline)
                .bold()
            Text("We couldn't find any events near you.")
                .font(.subheadline)
                .bold()
                .foregroundStyle(.secondary)
            Button(fetchEventsStatus.isRunning ? "Searching" : "Search again") {
                refreshFeed()
            }
            .disabled(fetchEventsStatus.isRunning)
            Spacer()
        }
    }
    
    private var searchingEventsProgressView: some View {
        VStack(alignment: .center, spacing: 15) {
            Spacer()
            ProgressView()
            Text("Searching for events...")
                .font(.headline)
                .bold()
            Spacer()
        }
    }
    
    private func refreshFeed() {
        Task {
            do {
                fetchEventsStatus = .running
                try await Task.sleep(for: .seconds(2))
                try await vm.refreshFeed()
                fetchEventsStatus = .success
            } catch {
                fetchEventsStatus = .failure(error)
            }
        }
    }
    
    
    private func fetchAdditionalEvents() {
        Task {
            do {
                fetchEventsStatus = .running
                try await vm.fetchAdditionalEvents()
                fetchEventsStatus = .success
            } catch {
                fetchEventsStatus = .failure(error)
            }
        }
    }
    
}

#Preview {
    DiscoveryEventList()
        .environment(EventStore())
}
