//
//  FriendAvatar.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

import SwiftUI

struct FriendAvatar: View {
    var imageURL: URL
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.lightCyan, .pacificCyan]),
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
