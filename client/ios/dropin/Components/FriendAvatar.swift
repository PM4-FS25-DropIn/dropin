//
//  FriendAvatar.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

import SwiftUI


/// Simple Circular Shaped Profile Image with a status ring.
/// Status Ring can be enabled by setting isHighlighted to true.
struct FriendAvatar: View {
    var imageURL: URL
    var isHighlighted = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: isHighlighted ? [.lightCyan, .pacificCyan] : [.gray, .black]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 7
                )
            
            Image(imageURL.absoluteString)
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
        }
        .frame(width: 60, height: 60)
    }
}

#Preview {
    FriendAvatar(imageURL: URL(filePath: "profileImage")!)
}
