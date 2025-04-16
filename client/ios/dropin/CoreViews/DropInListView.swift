//
//  DropInListView.swift
//  dropin
//
//

import SwiftUI

// MARK: - DUMMY SECTION

struct DummyDropInEvent: Identifiable, Hashable {
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
        latitude: 0,
        longitude: 0,
        maxSlots: 20,
        takenSlots: 5,
        visibility: .public,
        ageRestricted: false,
        chatEnabled: true,
        status: .upcoming
    ),
    DummyDropInEvent(
        id: 2,
        createdAt: Date(),
        title: "Community Meetup",
        description: "Casual meetup to chat about SwiftUI.",
        imagePaths: ["meetup.thumb"],
        userId: UUID(),  // someone else
        start: Date().addingTimeInterval(86400),
        end: Date().addingTimeInterval(90000),
        latitude: 0,
        longitude: 0,
        maxSlots: 50,
        takenSlots: 30,
        visibility: .public,
        ageRestricted: false,
        chatEnabled: false,
        status: .upcoming
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
        latitude: 0,
        longitude: 0,
        maxSlots: 10,
        takenSlots: 2,
        visibility: .public,
        ageRestricted: false,
        chatEnabled: true,
        status: .upcoming
    ),
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

// Tabs for switching
private enum Tab: CaseIterable {
    case all, mine

    var title: String {
        switch self {
        case .all:  return "All Events"
        case .mine: return "My Events"
        }
    }
}

// MARK: - DUMMY Row View
// can be replaced in the future

struct EventRowView: View {
    let event: DummyDropInEvent
    let isMine: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .top, spacing: 12) {
                // Placeholder image — replace with AsyncImage or your own
                Image(systemName: "calendar.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 6) {
                    Text(event.title)
                        .font(.headline)
                        .multilineTextAlignment(.leading)

                    Text(event.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    HStack {
                        Text(event.start, style: .date)
                            .font(.caption)
                        Spacer()
                        Text("\(event.takenSlots)/\(event.maxSlots) slots")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(
                // Card style background
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: Color.black.opacity(0.05),
                            radius: 4, x: 0, y: 2)
            )

            // A small “Yours” badge in the top‑right corner
            if isMine {
                Text("Yours")
                    .font(.caption2).bold()
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.accentColor.opacity(0.2))
                    )
                    .offset(x: -8, y: 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


#Preview {
    DropInListView()
}


