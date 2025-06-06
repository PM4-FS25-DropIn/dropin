//
//  FriendAvatar.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

import SwiftUI
import Kingfisher

/// Simple circular shaped thumbnail of the event.
///
/// Displays a circular shaped thumbnail of an event.
/// Includes a ring (border) that indicates the status of the event, which gets updated every minute.
struct EventBubble: View {
    
    let event: DropInEvent
    let ringColor: LinearGradient
    
    var body: some View {
        image
            .frame(width: 60, height: 60)
    }
    
    private var image: some View {
        Group {
            if let eventImagePath = event.imagePaths?.first {
                KFImage(URL(string: eventImagePath))
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .overlay(Circle().stroke(ringColor, lineWidth: 3))
            } else {
                Image("default.event.thumbnail")
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .background(
                        Circle()
                            .fill(Color(.systemBackground))
                    )
                    .overlay(Circle().stroke(ringColor, lineWidth: 3))
            }
        }
    }
    
    
}

#Preview {
    EventBubble(event: sampleEvent, ringColor: getEventStatusColorGradient(.upcoming))
}
