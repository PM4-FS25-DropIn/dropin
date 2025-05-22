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
    
    let joinEventAction: (DropInEvent) async throws -> Void
    
    @State private var username = "unknown"
    @State private var attendanceStatus: AttendanceStatus = .undetermined
    @State private var isShowingSheet = false
    @State private var isTimerFinished = false
    @State private var joinEventTaskStatus: AsyncStatus = .idle
    @State private var showAlert = false
    
    var body: some View {
        VStack(alignment: .leading) {
            eventImageCarousel
            VStack(alignment: .leading, spacing: 40) {
                eventCardBody
                joinSection
            }
            .padding()
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(radius: 2)
        .onAppear() {
            attendanceStatus = .undetermined
        }
        .onTapGesture {
            isShowingSheet = true
        }
        .sheet(isPresented: $isShowingSheet) {
            NavigationStack {
                EventDetailView(event: event, joinEventAction: joinEventAction)
            }
        }
        .alert("Error", isPresented: $showAlert) {
            Button("Ok", role: .cancel) { }
        } message: {
            Text(joinEventTaskStatus.error)
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
        .overlay(alignment: .topTrailing) {
            EventCardStatusBadge(status: event.status)
                .padding()
        }
    }
    
    private var countdown: some View {
        Group {
            if event.start > .now {
                EventCountdown(eventStartDate: event.start, isFinished: $isTimerFinished, formatter: formatter())
            }
        }
    }
    
    private func formatter() -> DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter
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
                Label(event.start.formatted(date: .omitted, time: .shortened), systemImage: "clock.badge.checkmark.fill")
                Label(event.end.formatted(date: .omitted, time: .shortened), systemImage: "clock.badge.xmark.fill")
                Label("\(event.slotsTaken ?? 1)/\(event.slotLimit) Slots", systemImage: "person.3.fill")
            }
            .font(.caption2)
            .foregroundColor(.gray)
            .padding(.top, 10)
        }
    }
    
    private var joinSection: some View {
        HStack {
            DropInButton(attendanceStatus: $attendanceStatus, action: joinEvent)
            if event.start > .now {
                Text("Starts in")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                EventCountdown(eventStartDate: event.start, isFinished: $isTimerFinished, formatter: formatter())
            }
        }
    }
    
    func joinEvent() {
        Task {
            joinEventTaskStatus = .running
            do {
                try await joinEventAction(event)
                joinEventTaskStatus = .success
                attendanceStatus = .joined
            } catch {
                joinEventTaskStatus = .failure(error)
                showAlert = true
            }
        }
    }

}

#Preview {
    EventCard(event: sampleEvent, joinEventAction: { _ in })
        .environment(EventStore())
}
