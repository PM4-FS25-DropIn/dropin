//
//  FriendAvatar.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

/// Simple Circular Shaped Profile Image with a status ring.
/// Status Ring can be enabled by setting isHighlighted to true.
import SwiftUI

struct FriendAvatar: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.lightCyan, .pacificCyan]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                )

            Image("profilepicture1")
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
        }
        .frame(width: 60, height: 60)
    }
}

#Preview {
    FriendAvatar()
}
