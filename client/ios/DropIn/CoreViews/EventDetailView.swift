import SwiftUI
import MapKit
import Kingfisher

/// Displays details about an event.
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
                MiniMap(event: event)
                OpenInMapsButton(event: event)
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
            if let eventImagePaths = event.imagePaths {
                ForEach(eventImagePaths, id: \.self) { imagePath in
                    KFImage.url(URL(string: imagePath))
                        .placeholder() {
                            ProgressView()
                        }
                        .resizable()
                        .scaledToFill()
                        .clipped()
                }
            } else {
                Image("default.event.thumbnail")
                    .resizable()
                    .scaledToFill()
                    .clipped()
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
    
    
    private var buttonGroup: some View {
        HStack {
            DropInButton(attendanceStatus: $attendanceStatus, action: joinEvent, extended: true)
            if !isHost {
                DropOutButton(attendanceStatus: $attendanceStatus, action: onLeaveButtonTapped)
            }
        }
    }
    
    // MARK: - Functions
    
    
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

