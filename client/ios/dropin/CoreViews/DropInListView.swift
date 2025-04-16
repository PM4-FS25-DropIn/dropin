//
//  DropInListView.swift
//  dropin
//
//

import SwiftUI

// MARK: - DUMMY SECTION

struct DummyDropInEvent: Identifiable {
    let id: Int
    let createdAt: Date
    let title: String
    let description: String
    let imagePaths: [String]
    let userId: UUID
    let start: Date
    let end: Date
    let latitude: Double
    let longitude: Double
    let maxSlots: Int
    let takenSlots: Int
    let visibility: Visibility
    let ageRestricted: Bool
    let chatEnabled: Bool
    let status: Status

    enum Visibility { case `public`, `private` }
    enum Status { case upcoming, live, completed }
}

// A dummy user ID for “current user”
private let currentUserId = UUID()

// Some locally defined dummy events for preview / testing
private let dummyEvents: [DummyDropInEvent] = [
    DummyDropInEvent(
        id: 1,
        createdAt: Date(),
        title: "My Hosted Workshop",
        description: "An awesome hands‑on coding workshop.",
        imagePaths: ["workshop.thumb"],
        userId: currentUserId,
        start: Date().addingTimeInterval(3600),
        end: Date().addingTimeInterval(7200),
        latitude: 0, longitude: 0,
        maxSlots: 20, takenSlots: 5,
        visibility: .public, ageRestricted: false,
        chatEnabled: true, status: .upcoming
    ),
    DummyDropInEvent(
        id: 2,
        createdAt: Date(),
        title: "Community Meetup",
        description: "Casual meetup to chat about SwiftUI.",
        imagePaths: ["meetup.thumb"],
        userId: UUID(), // someone else
        start: Date().addingTimeInterval(86400),
        end: Date().addingTimeInterval(90000),
        latitude: 0, longitude: 0,
        maxSlots: 50, takenSlots: 30,
        visibility: .public, ageRestricted: false,
        chatEnabled: false, status: .upcoming
    ),
    DummyDropInEvent(
        id: 3,
        createdAt: Date(),
        title: "Your Signed‑Up Event",
        description: "You’re attending this one—fun!",
        imagePaths: ["attend.thumb"],
        userId: currentUserId,
        start: Date().addingTimeInterval(172800),
        end: Date().addingTimeInterval(176400),
        latitude: 0, longitude: 0,
        maxSlots: 10, takenSlots: 2,
        visibility: .public, ageRestricted: false,
        chatEnabled: true, status: .upcoming
    )
]

// MARK: - END DUMMY SECTION

// MARK: - Main View

struct DropInListView: View {
    
    @State private var selectedTab: Tab = .all

    private var filteredEvents: [DummyDropInEvent] {
        switch selectedTab {
        case .all:
            return dummyEvents
        case .mine:
            return dummyEvents.filter { $0.userId == currentUserId }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                Picker("Events", selection: $selectedTab) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Text(tab.title).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // List of events
                List {
                    ForEach(filteredEvents) { event in
                        EventRowView(event: event,
                                     isMine: event.userId == currentUserId)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("DropIn Events")
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
}
