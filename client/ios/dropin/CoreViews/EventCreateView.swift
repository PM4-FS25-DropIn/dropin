import SwiftUI
import PhotosUI

struct EventCreateView: View {
    @Environment(EventStore.self) private var eventStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var launchState: AsyncStatus = .idle
    
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var event: DropInEvent = DropInEvent(title: "", description: "", imagePaths: ["default.event.thumbnail"], start: Date(), end: Date(), latitude: 0, longitude: 0, slotLimit: 2, ageRestricted: false, chatEnabled: true)
    
    @State private var showAlert = false
    
    var defaultEvent: DropInEvent?

    private let dateRange: ClosedRange<Date> = {
        let now = Date()
        let maxDate = Calendar.current.date(byAdding: .hour, value: 24, to: now) ?? .now
        return now...maxDate
    }()
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            VStack {
                Text("New DropIn")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.primary)
                    .padding()
                DropInEventForm(event: $event, selectedPhotos: $selectedPhotos, isEditing: false)
                    .onAppear {
                        if let defaultEvent {
                            event = defaultEvent
                        }
                    }

                Button("Launch") {
                    onLaunchButtonTapped()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .bold()
                .disabled(launchState.isRunning)
                .padding()
            }
        }
        .alert("Error", isPresented: $showAlert) {
            Button("Ok", role: .cancel) { }
        } message: {
            Text(launchState.error)
        }
    }
    
    
    private func onLaunchButtonTapped() {
        Task {
            launchState = .running
            
            do {
                try await eventStore.createEvent(event, photos: selectedPhotos)
                dismiss()
                launchState = .success
            } catch {
                launchState = .failure(error)
                showAlert = true
            }
        }
    }

}

#Preview {
    EventCreateView()
        .environment(EventStore())
}
