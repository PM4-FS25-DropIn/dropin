//
//  AppView.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

import SwiftUI

/// The entry point after successful authentication.
struct AppView: View {
    @State private var eventStore = EventStore()
    
    var body: some View {
        TabBar()
            .environment(eventStore)
            .onAppear {
                if !LocationService.shared.isEnabled {
                    print("Running enable")
                    LocationService.shared.enable()
                }
            }
    }
}

#Preview {
    AppView()
        .environment(AuthService())
}
