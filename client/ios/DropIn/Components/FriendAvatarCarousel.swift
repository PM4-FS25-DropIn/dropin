//
//  FriendAvatarCarousel.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

import SwiftUI

struct FriendAvatarCarousel: View {
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 15) {
                ForEach(1...10, id: \.self) { _ in
                    FriendAvatar()
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
