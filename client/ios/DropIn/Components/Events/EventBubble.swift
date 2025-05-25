//
//  FriendAvatar.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

/// Simple circular shaped thumbnail of the event.
/// Has a border that indicates the status of the event, which gets updated every minute.
import SwiftUI

struct EventBubble: View {
    
    @State private var currentDate = Date()
    @State private var ringColor: LinearGradient
    
    let event: DropInEvent
    
    init(event: DropInEvent) {
        self.event = event
        _ringColor = State(wrappedValue: getEventStatusColorGradient(event.status))
    }
    
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        image
            .frame(width: 60, height: 60)
            .onReceive(timer) { time in
                currentDate = time
                ringColor = getEventStatusColorGradient(event.status)
            }
    }
    
    private var image: some View {
        Group {
            if let eventImagePath = event.imagePaths?.first {
                AsyncImage(url: URL(string: eventImagePath)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                            .overlay(Circle().stroke(getEventStatusColorGradient(event.status), lineWidth: 3))
                    } else if phase.error != nil {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                    } else {
                        ProgressView()
                    }
                }
            } else {
                Image("default.event.thumbnail")
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .background(
                        Circle()
                            .fill(Color(.systemBackground))
                    )
                    .overlay(Circle().stroke(getEventStatusColorGradient(event.status), lineWidth: 3))
            }
        }
    }
    
    
}

#Preview {
    EventBubble(event: sampleEvent)
}
