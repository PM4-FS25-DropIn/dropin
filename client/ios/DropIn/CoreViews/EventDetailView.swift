import SwiftUI

struct EventDetailView: View {
    @Environment(EventStore.self) private var eventStore
    
    @State private var joinEventTaskStatus: AsyncStatus = .idle
    @State private var attendanceStatus: AttendanceStatus = .undetermined
    
    var event: DropInEvent
    
    var body: some View {
        ScrollView {
            TabView {
                ForEach(event.imagePaths, id: \.self) { imagePath in
                    image(imagePath: imagePath)
                }
            }
            .tabViewStyle(.page)
            .containerRelativeFrame(.vertical, count: 12, span: 5, spacing: 0)
            Text(event.title)
                .font(.title)
                .bold()
            Text(event.description)
                .font(.subheadline)
            buttonGroup
            EventQuickInfo(event: event)
                .padding()
            Spacer()
        }
        .onAppear {
            attendanceStatus = eventStore.checkIfEventIsJoinedByUser(event) ? .joined : .undetermined
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
    
    private var buttonGroup: some View {
        DropInButton(attendanceStatus: $attendanceStatus, action: joinEvent, extended: true)
            .padding()
    }
    
    private func joinEvent() {
        Task {
            joinEventTaskStatus = .running
            do {
                try await eventStore.joinEvent(event)
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

