import SwiftUI

struct HomeView: View {
    
    var body: some View {
        NavigationStack {
            VStack {
                header
                FriendAvatarCarousel()
                DiscoveryEventList()
            }
        }
    }
    
    private var header: some View {
        HStack {
            NavigationLink(destination: EmptyView()) {
                Image(systemName: "bell.fill")
            }
            Spacer()
            NavigationLink(destination: ChatListView()) {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(.primary)
            }
        }
        .font(.title2)
        .padding(.horizontal)
    }
}

#Preview {
    HomeView()
        .environment(AuthService())
        .environment(EventStore())
}

