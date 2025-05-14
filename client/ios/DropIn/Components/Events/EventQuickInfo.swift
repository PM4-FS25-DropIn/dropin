//
//  EventQuickInfo.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

import SwiftUI

struct EventQuickInfo: View {
    @Environment(EventStore.self) private var eventStore

    @State private var organizer = ""

    var event: DropInEvent

    var body: some View {
        VStack(spacing: 20) {
            header
            quickInfoGrid
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }

    private var header: some View {
        VStack(alignment: .center, spacing: 5) {
            Image(systemName: "megaphone.fill")
                .font(.title)
                .foregroundStyle(.accent)
            Text("Event Quick Info")
                .font(.subheadline)
                .bold()
            Text("Everything you should know before joining")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var quickInfoGrid: some View {
        Grid(alignment: .leading, verticalSpacing: 15) {
            GridRow {
                infoItem(organizer, "person.fill")
                    .task {
                        do {
                            organizer = try await eventStore.getHostUsername(
                                of: event
                            )
                        } catch {
                            organizer = "Unknown"
                        }
                    }
                infoItem(
                    "\(event.slotsTaken ?? 1)/\(event.slotLimit) Slots",
                    "person.3.fill"
                )
            }
            GridRow {
                infoItem(
                    event.start.formatted(date: .numeric, time: .shortened),
                    "clock.badge.checkmark.fill"
                )
                infoItem(
                    event.end.formatted(date: .numeric, time: .shortened),
                    "clock.badge.xmark.fill"
                )
            }
            GridRow {
                infoItem(
                    "\(event.chatEnabled ? "Enabled" : "Disabled")",
                    "bubble.left.and.bubble.right.fill"
                )
                infoItem(
                    "\(event.ageRestricted ? "Age Restricted" : "All Ages")",
                    "hand.raised.palm.facing.fill"
                )
            }
        }
    }

    private func infoItem(_ text: String, _ systemImage: String) -> some View {
        HStack {
            Image(systemName: systemImage)
                .font(.subheadline)
                .frame(width: 30, alignment: .center)
            Text(text)
                .font(.subheadline)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    EventQuickInfo(event: sampleEvent)
        .environment(EventStore())
}
