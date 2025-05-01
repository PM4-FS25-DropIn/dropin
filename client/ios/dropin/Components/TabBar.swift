//
//  TabBar.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

import SwiftUI

struct TabBar: View {
    @State private var isSheetPresented = false
    
    var body: some View {
        ZStack {
            coreViews
            eventHubActionButton
        }
        .sheet(isPresented: $isSheetPresented) {
            // Show the cockpit for your events here
            // TODO: implement cockpit, use EventCreateView and EventEditView components
            Text("Create new dropin")
        }
    }
    
    var eventHubActionButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    isSheetPresented.toggle()
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .padding()
                        .background(.accent)
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                        .frame(width: 100, height: 50)
                }
                Spacer()
            }
        }
    }
    
    var coreViews: some View {
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone

        return VStack {
            TabView {
                Tab("Home", systemImage: "house") {
                    HomeView()
                }
                Tab("Map", systemImage: "map") {
                    // Mapview here
                    MapView()
                }
                if isPhone {
                    Tab() {
                        Spacer()
                    }
                }
                Tab("DropIns", systemImage: "drop.fill") {
                    // The view with dropins you've joined
                    // TODO
                }
                Tab("Profile", systemImage: "person") {
                    // Profile View here
                    ProfileView()
                }
            }
            .tabViewStyle(DefaultTabViewStyle())
        }
    }
}

#Preview {
    TabBar()
}
