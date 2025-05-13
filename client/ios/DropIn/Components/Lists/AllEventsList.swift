//
//  AllEventsList.swift
//  dropin
//
//  Created on 01/05/2025.
//


import SwiftUI


/// Displays a list of joined events of user
struct AllEventsList: View {
    @Environment(EventStore.self) private var eventStore
    @Environment(AuthService.self) private var authService
    
    @State private var onSwipeActionStatus: AsyncStatus = .idle
    @State private var showAlert = false
    
    var body: some View {
        List {
            ForEach(eventStore.joinedEvents) { event in
                EventRowItem(event: event, isHost: event.userId == authService.userId)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            event.userId == authService.userId ?
                            onDeleteSwipeAction(event) : onLeaveSwipeAction(event)
                        } label: {
                            event.userId == authService.userId ?
                            Label("Delete", systemImage: "trash")
                            :
                            Label("Drop Out", systemImage: "figure.walk.departure")
                        }
                    }
            }
        }
        .scrollContentBackground(.hidden)
        .alert("Error", isPresented: $showAlert) {
            Button("Ok", role: .cancel) { }
        } message: {
            Text(onSwipeActionStatus.error)
        }
    }
    
    
    private func onLeaveSwipeAction(_ event: DropInEvent) {
        Task {
            onSwipeActionStatus = .running
            
            do {
                try await eventStore.leaveEvent(event)
                onSwipeActionStatus = .success
            } catch {
                onSwipeActionStatus = .failure(error)
                showAlert = true
            }
        }
    }
    
    private func onDeleteSwipeAction(_ event: DropInEvent) {
        Task {
            onSwipeActionStatus = .running
            
            do {
                try await eventStore.deleteEvent(event)
                onSwipeActionStatus = .success
            } catch {
                onSwipeActionStatus = .failure(error)
                showAlert = true
            }
        }
    }
}

#Preview {
    AllEventsList()
        .environment(EventStore())
        .environment(AuthService())
}
