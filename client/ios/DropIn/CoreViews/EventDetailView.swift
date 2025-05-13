import SwiftUI

struct EventDetailView: View {
    @Environment(EventStore.self) private var eventStore
    
    @State private var joinEventTaskStatus: AsyncStatus = .idle
    
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
        Button {
            joinEvent()
        } label: {
            Text("Drop In")
                .frame(maxWidth: .infinity)
                .bold()
        }
        .buttonStyle(.borderedProminent)
        .padding()
        .disabled(joinEventTaskStatus.isRunning)
    }
    
    private func joinEvent() {
        Task {
            joinEventTaskStatus = .running
            do {
                try await eventStore.joinEvent(event)
                joinEventTaskStatus = .success
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

