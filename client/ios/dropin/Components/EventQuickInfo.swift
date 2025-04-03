//
//  EventQuickInfo.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

import SwiftUI

struct EventQuickInfo: View {
    var event: DropInEvent
    
    var body: some View {
        VStack(spacing: 20) {
            header
            quickInfoGrid
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
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
                infoItem("Organizer", "person.fill")
                infoItem("\(event.takenSlots)/\(event.maxSlots) Slots", "person.3.fill")
            }
            GridRow {
                infoItem(event.start.formatted(date: .omitted, time: .shortened), "play.circle.fill")
                infoItem(event.end.formatted(date: .omitted, time: .shortened), "stop.circle.fill")
            }
            GridRow {
                infoItem("Public", "eye")
                infoItem("\(event.ageRestricted ? "Age Restricted" : "Not Age Restricted")", "hand.raised.palm.facing.fill")
            }
            GridRow {
                infoItem("Location", "mappin.and.ellipse")
                infoItem("\(event.chatEnabled ? "Enabled" : "Disabled")", "bubble.left.and.bubble.right.fill")
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
    EventQuickInfo(event: dummyEvent)
}
