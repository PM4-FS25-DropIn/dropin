//
//  EventCard.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

import SwiftUI

struct EventCard: View {
    @Environment(EventStore.self) private var eventStore
    
    let event: DropInEvent
    var onJoinHandler: (DropInEvent) async throws -> Void
    
    @State private var username = "unknown"
    @State private var attendanceStatus: AttendanceStatus = .undetermined
    @State private var isShowingSheet = false
   
    
    var body: some View {
        VStack(alignment: .leading) {
            eventImageCarousel
            VStack(alignment: .leading, spacing: 40) {
                eventCardBody
                buttonGroup
            }
            .padding()
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 5)
        .onAppear() {
            attendanceStatus = .undetermined
        }
        .onTapGesture {
            isShowingSheet = true
        }
        .sheet(isPresented: $isShowingSheet) {
            EventDetailView(event: event)
        }
    }
    
    private var eventImageCarousel: some View {
        TabView {
            ForEach(event.imagePaths, id: \.self) { imagePath in
                AsyncImage(url: URL(string: imagePath)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .clipped()
                    } else if phase.error != nil {
                        ContentUnavailableView("Image Unavailable", systemImage: "exclamationmark.circle.fill")
                    } else {
                        ProgressView()
                    }
                }
            }
        }
        .tabViewStyle(.page)
        .containerRelativeFrame(.vertical, count: 12, span: 5, spacing: 0)
        .overlay {
            EventCardStatusBadge(status: event.status)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding()
        }
    }
    
    private var eventCardBody: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(event.title)
                .font(.headline)
            
            Text(event.description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 12) {
                Label(username, systemImage: "person.fill")
                    .task {
                        do {
                            username = try await eventStore.getHostUsername(of: event)
                        } catch {
                            print("Couldn't get username")
                        }
                    }
                Label(event.start.formatted(date: .omitted, time: .shortened), systemImage: "play.circle.fill")
                Label(event.end.formatted(date: .omitted, time: .shortened), systemImage: "stop.circle.fill")
                Label("\(event.slotsTaken ?? 1)/\(event.slotLimit) Slots", systemImage: "person.3.fill")
            }
            .font(.caption2)
            .foregroundColor(.gray)
            .padding(.top, 10)
        }
    }
    
    private var buttonGroup: some View {
        HStack(spacing: 15) {
            Button(attendanceStatus == .joined ? "Dropped In" : "Drop In") {
                Task {
                    do {
                        try await onJoinHandler(event)
                        attendanceStatus = .joined
                        print("Joined event")
                    } catch {
                        print("Couldn't join event")
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 15))
            .font(.subheadline)
            .disabled(attendanceStatus == .joined)
        }
    }
}

#Preview {
    EventCard(event: sampleEvent, onJoinHandler: { event in })
        .environment(EventStore())
}
