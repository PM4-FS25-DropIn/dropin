import SwiftUI

struct EventEditView: View {
    @Environment(EventStore.self) private var eventService
    @Environment(\.dismiss) private var dismiss
    
    @State var event: DropInEvent
    @State private var updateAsyncState: AsyncStatus = .idle
    
    @State private var showConfirmationAlert = false
    @State private var showErrorAlert = false
    
    init(event: DropInEvent) {
        self._event = State(initialValue: event)
    }
   
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            VStack {
                Text("Edit Event")
                    .font(.title)
                    .bold()
                //DropInEventForm(event: $event, selectedPhotos: $ isEditing: true)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Update") {
                        showConfirmationAlert = true
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Confirm Updates", isPresented: $showConfirmationAlert) {
            Button("Confirm") {
                onUpdateButtonTapped()
                showConfirmationAlert = false
            }
            Button("Cancel", role: .cancel) {
                showConfirmationAlert = false
            }
        } message: {
            Text("Are you sure you want to apply these changes?")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("Ok", role: .cancel) {
                showErrorAlert = false
            }
        } message: {
            Text(updateAsyncState.error)
        }
    }
    
    private func onUpdateButtonTapped() {
        Task {
            updateAsyncState = .running
            
            do {
                try await eventService.updateEvent(event)
                dismiss()
                updateAsyncState = .success
            } catch {
                print("Error")
                updateAsyncState = .failure(error)
                if showConfirmationAlert {
                    showConfirmationAlert = false
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

