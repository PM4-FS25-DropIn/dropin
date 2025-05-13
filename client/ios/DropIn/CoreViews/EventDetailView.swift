import SwiftUI
import MapKit

struct EventDetailView: View {
    @Environment(EventStore.self) private var eventStore
    
    @State private var joinEventTaskStatus: AsyncStatus = .idle
    @State private var attendanceStatus: AttendanceStatus = .undetermined
    
    var event: DropInEvent
    var isHost: Bool = true
    
    var body: some View {
        ScrollView {
            imageCarousel
            VStack(alignment: .center, spacing: 20) {
                titleAndDescription
                DropInButton(attendanceStatus: $attendanceStatus, action: joinEvent, extended: true)
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
        }
    }
    
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
    
    // MARK: - Join Event Function
    
    private func joinEvent() {
        Task {
            joinEventTaskStatus = .running
            do {
                _ = try await eventStore.joinEvent(event)
                joinEventTaskStatus = .success
                attendanceStatus = .joined
            } catch {
                joinEventTaskStatus = .failure(error)
            }
        }
    }
   
}

#Preview {
    EventDetailView(event: sampleEvent)
        .environment(EventStore())
}

