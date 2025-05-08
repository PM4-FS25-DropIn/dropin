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
    var showHostBadge: Bool = true
    
    var body: some View {
        HStack {
            rowImage
            rowContent
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
    
    private var rowImage: some View {
        AsyncImage(url: URL(string: event.imagePaths[0])) { image in
            image
                .resizable()
                .scaledToFill()
                .containerRelativeFrame([.horizontal], count: 10, span: 4, spacing: 0)
                .clipped()
        } placeholder: {
            ProgressView()
        }
    }
    
    private var rowContent: some View {
        VStack(alignment: .leading)  {
            HStack {
                Text(event.title)
                    .font(.headline)
                    .scaledToFit()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                if showHostBadge {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
            }
            Text(event.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .scaledToFit()
                .minimumScaleFactor(0.2)
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
    }
}

#Preview {
    EventRowItem(event: sampleEvent)
}
