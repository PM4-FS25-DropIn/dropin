import SwiftUI

/// The home view of the app.
struct HomeView: View {
    
    var body: some View {
        VStack {
            header
            EventTimeLine()
                .padding(.vertical)
            Divider()
            DiscoveryEventList()
        }
    }
    
    private var header: some View {
        HStack {
            NavigationLink(destination: EmptyView()) {
                Image(systemName: "bell.fill")
                    .foregroundStyle(.accent)
            }
            Spacer()
            NavigationLink(destination: ChatListView()) {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(.accent)
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

