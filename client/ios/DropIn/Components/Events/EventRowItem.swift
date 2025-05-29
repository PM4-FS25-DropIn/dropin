//
//  EventRowItem.swift
//  dropin
//
//  Created on 01/05/2025.
//


import SwiftUI
import Kingfisher

struct EventRowItem: View {
    
    @State private var showDetailsView = false
    
    let event: DropInEvent
    var isHost: Bool = false
    
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
            NavigationStack {
                EventDetailView(event: event, isHost: isHost, joinEventAction: { _ in })
            }
        }
        .overlay(alignment: .topTrailing) {
            Circle().fill(getEventStatusColorGradient(event.status))
                .frame(width: 5, height: 5)
                .padding()
        }
        .frame(height: 150)
    }
    
    private var rowImage: some View {
        Group {
            if let eventImagePath = event.imagePaths?.first {
                KFImage(URL(string: eventImagePath)!)
                    .resizable()
                    .scaledToFill()
                    .containerRelativeFrame([.horizontal], count: 10, span: 4, spacing: 0)
                    .clipped()
            }
            /*
            if let eventImagePath = event.imagePaths?.first {
                AsyncImage(url: URL(string: eventImagePath)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .containerRelativeFrame([.horizontal], count: 10, span: 4, spacing: 0)
                            .clipped()
                    } else if phase.error != nil {
                        VStack(spacing: 5) {
                            Image(systemName: "exclamationmark.circle.fill")
                            Text("Image Unavailable")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .scaledToFill()
                        .clipped()
                    } else {
                        ProgressView()
                    }
                }
            } else {
                Image("default.event.thumbnail")
                    .resizable()
                    .scaledToFill()
                    .containerRelativeFrame([.horizontal], count: 10, span: 4, spacing: 0)
                    .clipped()
            }
            */
        }
    }
    
    private var rowContent: some View {
        VStack(alignment: .leading)  {
            HStack {
                Text(event.title)
                    .font(.headline)
                    .lineLimit(1)
                if isHost {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
            }
            Text(event.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Spacer()
            VStack(alignment: .leading) {
                Label(event.start.formatted(date: .numeric, time: .shortened), systemImage: "clock.badge.checkmark.fill")
                Label(event.end.formatted(date: .numeric, time: .shortened), systemImage: "clock.badge.xmark.fill")
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
