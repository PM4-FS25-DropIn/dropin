import SwiftUI
import MapKit

struct EventDetailView: View {
    @Environment(EventStore.self) private var eventStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var eventAsyncTaskStatus: AsyncStatus = .idle
    @State private var attendanceStatus: AttendanceStatus = .undetermined
    @State private var showLeaveConfirmation = false
    
    var event: DropInEvent
    var isHost: Bool = false
    let joinEventAction: (DropInEvent) async throws -> Void
    
    var body: some View {
        ScrollView {
            imageCarousel
            VStack(alignment: .center, spacing: 20) {
                titleAndDescription
                buttonGroup
                EventQuickInfo(event: event)
                minimap
            }
            .padding()
        }
        .toolbar(.hidden)
        .scrollIndicators(.hidden)
        .onAppear {
            attendanceStatus = eventStore.checkIfEventIsJoinedByUser(event) ? .joined : .undetermined
        }
        .alert("Confirm Dropout", isPresented: $showLeaveConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Drop Out", role: .destructive) {
                leaveEvent()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to leave this event?")
        }
       
    }
    
    // MARK: - Image Carousel
    
    private var imageCarousel: some View {
        TabView {
            ForEach(event.imagePaths, id: \.self) { imagePath in
                image(imagePath: imagePath)
            }
        }
        .tabViewStyle(.page)
        .containerRelativeFrame(.vertical, count: 12, span: 5, spacing: 0)
        .overlay(alignment: .topTrailing) {
            if isHost {
                NavigationLink("Edit") {
                    EventEditView(event: event)
                }
                .font(.footnote)
                .bold()
                .foregroundStyle(.white)
                .padding(10)
                .background(.accent)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .padding()
            }
        }
    }
    
    // MARK: - Title and Description
    
    private var titleAndDescription: some View {
        VStack(alignment: .center) {
            if isHost {
                Image(systemName: "crown.fill")
                    .foregroundStyle(.orange)
                    .font(.caption)
            }
            Text(event.title)
                .font(.title)
                .bold()
            Text(event.description)
                .font(.caption)
                .bold()
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Minimap
    
    private var minimap: some View {
        VStack {
            Text("Location")
                .font(.title2)
                .bold()
            Text(formatCoordinates(latitude: event.latitude, longitude: event.longitude))
                .font(.caption)
                .bold()
                .foregroundStyle(.secondary)
            Map(initialPosition: .region(MKCoordinateRegion(center: .init(latitude: event.latitude, longitude: event.longitude), span: .init(latitudeDelta: 0.001, longitudeDelta: 0.001)))) {
                Marker("DropIn", systemImage: "drop", coordinate: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude))
                    .tint(.indigo)
            }
            .disabled(true)
            .containerRelativeFrame(.vertical, count: 12, span: 4, spacing: 0)
            .mapControlVisibility(.hidden)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Button {
                let destination = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
                let url = URL(string: "http://maps.apple.com/?daddr=\(destination.latitude),\(destination.longitude)")!
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
            } label: {
                Label("Open in Maps", systemImage: "map")
                    .font(.subheadline)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(12)
            }
        }
    }
    
    
    private var buttonGroup: some View {
        HStack {
            DropInButton(attendanceStatus: $attendanceStatus, action: joinEvent, extended: true)
            if !isHost {
                DropOutButton(attendanceStatus: $attendanceStatus, action: onLeaveButtonTapped)
            }
        }
    }
    
    // MARK: - Functions
    
    private func image(imagePath: String) -> some View {
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
    
    
    private func joinEvent() {
        Task {
            eventAsyncTaskStatus = .running
            do {
                try await joinEventAction(event)
                eventAsyncTaskStatus = .success
                attendanceStatus = .joined
            } catch {
                eventAsyncTaskStatus = .failure(error)
            }
        }
    }
    
    private func onLeaveButtonTapped() {
        showLeaveConfirmation = true
    }
   
    private func leaveEvent() {
        Task {
            eventAsyncTaskStatus = .running
            do {
                _ = try await eventStore.leaveEvent(event)
                eventAsyncTaskStatus = .success
                attendanceStatus = .undetermined
            } catch {
                eventAsyncTaskStatus = .failure(error)
            }
        }
    }
}

#Preview {
    EventDetailView(event: sampleEvent, joinEventAction: { _ in })
        .environment(EventStore())
}

