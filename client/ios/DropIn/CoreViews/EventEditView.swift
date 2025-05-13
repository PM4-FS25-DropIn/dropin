import SwiftUI
import PhotosUI
import MapKit

struct EventEditView: View {
    @Environment(EventStore.self) private var eventStore
    @Environment(\.dismiss) private var dismiss
    
    @State var event: DropInEvent
    @State var isEditTimeExpired = false
    
    @State private var asyncTaskStatus: AsyncStatus = .idle
    
    @State private var showUpdateConfirmation = false
    @State private var showDeleteConfirmation = false
    @State private var showErrorAlert = false
    
    init(event: DropInEvent) {
        self._event = State(initialValue: event)
    }
   
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                titleAndDescription
                map
                time
                participants
            }
            .padding()
            deleteButton
                .padding()
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Edit DropIn")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Update") {
                    showUpdateConfirmation = true
                }
                .disabled(isEditTimeExpired)
            }
        }
        .alert("Confirm Updates", isPresented: $showUpdateConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Update") {
                onUpdateButtonTapped()
                showUpdateConfirmation = false
            }
        } message: {
            Text("Are you sure you want to update this event?")
        }
        .alert("Confirm Delete", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDeleteButtonTapped()
                showDeleteConfirmation = false
            }
        } message: {
            Text("You will not be able to recover this event.")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("Ok", role: .cancel) {
                showErrorAlert = false
            }
        } message: {
            Text(asyncTaskStatus.error)
        }
        notice
    }
    
    // MARK: - Notice Footer
    
    private var notice: some View {
        Group {
            Text("You can edit your event up to 30min before start.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            if !isEditTimeExpired {
                EventCountdown(eventStartDate: event.start.addingTimeInterval(-30 * 60), isFinished: $isEditTimeExpired)
            } else {
                Text("This event can no longer be edited.")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .bold()
            }
        }
        .onAppear {
            if event.start.timeIntervalSinceNow < 30 * 60 {
                isEditTimeExpired = true
            }
        }
    }
    
    // MARK: - Title and Description
    
    private var titleAndDescription: some View {
        Group {
            Text("Title and Description")
                .font(.title2)
                .bold()
            VStack {
                TextField(event.title, text: $event.title)
                TextField(event.description, text: $event.description)
            }
            .autocorrectionDisabled()
            .disabled(isEditTimeExpired)
            .foregroundStyle(isEditTimeExpired ? .secondary : .primary)
        }
    }
    
    // MARK: - Map
    
    private var map: some View {
        Group {
            Text("Location")
                .font(.title2)
                .bold()
            Map(initialPosition: .region(MKCoordinateRegion(center: .init(latitude: event.latitude, longitude: event.longitude), span: .init(latitudeDelta: 0.001, longitudeDelta: 0.001)))) {
                Marker("DropIn", systemImage: "drop", coordinate: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude))
                    .tint(.indigo)
            }
            .disabled(true)
            .containerRelativeFrame(.vertical, count: 12, span: 4, spacing: 0)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .mapControlVisibility(.hidden)
        }
    }
    
    // MARK: - Start and End Time
    
    private var time: some View {
        Group {
            Text("Time")
                .font(.title2)
                .bold()
            VStack {
                HStack {
                    Text("Start")
                    Spacer()
                    Text(event.start.formatted(date: .abbreviated, time: .shortened))
                }
                HStack {
                    Text("End")
                    Spacer()
                    Text(event.end.formatted(date: .abbreviated, time: .shortened))
                }
            }
            .foregroundStyle(isEditTimeExpired ? .secondary : .primary)
        }
    }
    
    // MARK: - Participants
    
    private var participants: some View {
        Group {
            Text("Participants")
                .font(.title2)
                .bold()
            Group {
                HStack {
                    Text("Max Slots: \(event.slotLimit)")
                        .frame(minWidth: 120, alignment: .leading)
                    Slider(
                        value: Binding(
                            get: { Double(event.slotLimit) },
                            set: { event.slotLimit = Int($0) }
                        ),
                        in: max(2, Double(event.slotsTaken ?? 2))...100,
                        step: 1,
                        onEditingChanged: { _ in }
                    )
                    
                }
                Toggle(isOn: $event.ageRestricted) {
                    Text("Age Restricted")
                }
            }
            .disabled(isEditTimeExpired)
            .foregroundStyle(isEditTimeExpired ? .secondary : .primary)
        }
    }
    
    // MARK: - Delete Button
    
    private var deleteButton: some View {
        Button("Delete") {
            showDeleteConfirmation = true
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 30))
        .tint(.red)
    }
    
    // MARK: - Functions
    
    private func onDeleteButtonTapped() {
        Task {
            asyncTaskStatus = .running
            
            do {
                try await eventStore.deleteEvent(event)
                dismiss()
                dismiss()
                asyncTaskStatus = .success
            } catch {
                asyncTaskStatus = .failure(error)
                if showUpdateConfirmation || showDeleteConfirmation {
                    showUpdateConfirmation = false
                    showDeleteConfirmation = false
                    showErrorAlert = true
                } else {
                    showErrorAlert = true
                }
            }
        }
    }
    
    private func onUpdateButtonTapped() {
        Task {
            asyncTaskStatus = .running
            
            do {
                try await eventStore.updateEvent(event)
                asyncTaskStatus = .success
            } catch {
                asyncTaskStatus = .failure(error)
                if showUpdateConfirmation || showDeleteConfirmation {
                    showUpdateConfirmation = false
                    showDeleteConfirmation = false
                    showErrorAlert = true
                } else {
                    showErrorAlert = true
                }
            }
        }
    }
}

#Preview {
    EventEditView(event: sampleEvent)
        .environment(EventStore())
}

