//
//  MapEventItemDetailSheet.swift
//  dropin
//
//  Created by Moritz Feuchter on 01/05/2025.
//


import SwiftUI
@preconcurrency import MapKit

struct MapEventItemDetailSheet: View {
    @Environment(EventStore.self) private var eventStore
    
    @State private var lookAroundScene: MKLookAroundScene?
    @State private var attendanceStatus: AttendanceStatus = .undetermined
    @State private var joinEventTaskStatus: AsyncStatus = .idle
    @State private var showAlert = false
    
    var viewModel: EventMapViewModel
    var event: DropInEvent
    var travelTime: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            EventStatusBadge(status: event.status)
            header
            detailsScrollView
        }
        .padding()
        .alert("Error", isPresented: $showAlert) {
            Button("Ok", role: .cancel) { }
        } message: {
            Text(joinEventTaskStatus.error)
        }
        .ignoresSafeArea()
    }
    
    var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.title)
                    .bold()
                Text(formatCoordinates(latitude: event.latitude, longitude: event.longitude))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .bold()
                estimatedTimeDisplay
            }
            Spacer()
            dropInButton
        }
    }
    
    var detailsScrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                sectionTitle("About")
                descriptionBox
                sectionTitle("Quick Info")
                EventQuickInfo(event: event)
                sectionTitle("Gallery")
                eventImagesCarousel
                OpenInMapsButton(event: event)
            }
        }
        .scrollIndicators(.hidden)
    }
    
    var descriptionBox: some View {
        VStack(alignment: .leading) {
            Text(event.description)
                .lineLimit(5)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 30))
    }
    
    func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .bold()
    }
    
    var dropInButton: some View {
        HStack(spacing: 15) {
            DropInButton(attendanceStatus: $attendanceStatus) {
               joinEvent()
            }
            .onAppear {
                if let id = event.id {
                    attendanceStatus = eventStore.getAttendanceStatus(of: id)
                    print("Attendance status is: \(attendanceStatus.rawValue)")
                }
            }
        }
    }
    
    var eventImagesCarousel: some View {
        TabView {
            if let eventImagePaths = event.imagePaths {
                ForEach(eventImagePaths, id: \.self) { imagePath in
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
            } else {
                Image("default.event.thumbnail")
                    .resizable()
                    .scaledToFill()
                    .clipped()
            }
        }
        .tabViewStyle(.page)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .containerRelativeFrame(.vertical, count: 12, span: 5, spacing: 0)
    }
    
    var estimatedTimeDisplay: some View {
        HStack {
            Image(systemName: "figure.walk")
            Text(travelTime ?? "N/A")
                .bold()
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    
    func joinEvent() {
        Task {
            joinEventTaskStatus = .running
            do {
                _ = try await eventStore.joinEvent(event)
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
    MapEventItemDetailSheet(viewModel: EventMapViewModel(), event: sampleEvent)
        .environment(EventStore())
}
