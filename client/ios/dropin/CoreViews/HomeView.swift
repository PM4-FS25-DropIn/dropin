import SwiftUI

struct HomeView: View {
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "bell.fill")
                    .padding(.horizontal)
                    .foregroundStyle(.secondary)
            }
            FriendAvatarCarousel()
            DiscoveryEventList()
        }
    }
    
}

#Preview {
    HomeView()
        .environment(AuthService())
}

