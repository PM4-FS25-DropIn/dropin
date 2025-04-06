//
//  FriendAvatarCarousel.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

import SwiftUI

struct FriendAvatarCarousel: View {
    var imageURLs: [URL] = [URL(filePath: "")!]// just for testing, should later be used with actual fetched profiles from the database
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 15) {
                ForEach(1...10, id: \.self) { _ in
                    FriendAvatar(imageURL: URL(filePath: "")!)
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    FriendAvatarCarousel()
}
