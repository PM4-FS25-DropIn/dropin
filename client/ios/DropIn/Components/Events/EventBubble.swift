//
//  FriendAvatar.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

/// Simple circular shaped thumbnail of the event.
/// Has a border that indicates the status of the event, which gets updated every minute.
import SwiftUI
import Kingfisher

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
                /*AsyncImage(url: URL(string: eventImagePath)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                            .overlay(Circle().stroke(ringColor, lineWidth: 3))
                    } else if phase.error != nil {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                    } else {
                        ProgressView()
                    }
                }*/
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
