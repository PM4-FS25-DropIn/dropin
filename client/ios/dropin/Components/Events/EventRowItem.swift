//
//  EventRowItem.swift
//  dropin
//
//  Created on 01/05/2025.
//


import SwiftUI

struct EventRowItem: View {
    
    @State private var showDetailsView = false
    
    let event: DropInEvent
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: event.imagePaths[0])) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .containerRelativeFrame(.horizontal, count: 10, span: 4, spacing: 0)
                        .clipped()
                }
            }
            VStack(alignment: .leading)  {
                Text(event.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(event.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Spacer()
                VStack(alignment: .leading) {
                    Label(event.start.formatted(date: .omitted, time: .shortened), systemImage: "play.circle.fill")
                    Label(event.end.formatted(date: .omitted, time: .shortened), systemImage: "stop.circle.fill")
                    Label(formatCoordinates(latitude: event.latitude, longitude: event.longitude), systemImage: "mappin.and.ellipse")
                        .lineLimit(1)
                    Label("\(event.slotsTaken ?? 1)/\(event.slotLimit) Slots", systemImage: "person.3.fill")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            .padding()
            Spacer()
        }
        .background(.gray.opacity(0.1))
        .onTapGesture {
            showDetailsView = true
        }
        .sheet(isPresented: $showDetailsView) {
            EventDetailView(event: event)
        }
    }
}

#Preview {
    EventRowItem(event: sampleEvent)
}
