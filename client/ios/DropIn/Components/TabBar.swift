//
//  TabBar.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

import SwiftUI
import MapKit

/// The app's tabbbar.
struct TabBar: View {
    @State private var isSheetPresented = false

    var body: some View {
        ZStack {
            coreViews
            eventHubActionButton
        }
        .sheet(isPresented: $isSheetPresented) {
            CreateEventWizard()
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
                        .bold()
                        .background(.accent)
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                        .frame(width: 100, height: 50)
                }
                Spacer()
            }
        }
        .ignoresSafeArea(.keyboard)
    }

    var coreViews: some View {
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone

        return VStack {
            TabView {
                Tab("Home", systemImage: "house") {
                    NavigationStack {
                        HomeView()
                    }
                }
                Tab("Map", systemImage: "map") {
                    MapView()
                }
                if isPhone {
                    Tab {
                        Spacer()
                    }
                }
                Tab("DropIns", systemImage: "drop.fill") {
                    NavigationStack {
                        DropInsView()
                            .navigationTitle("Up Next")
                    }
                }
                Tab("Profile", systemImage: "person.circle") {
                    NavigationStack {
                        ProfileView()
                    }
                }
            }
            .tabViewStyle(DefaultTabViewStyle())
        }
    }
}

#Preview {
    TabBar()
        .environment(AuthService())
        .environment(EventStore())
}
