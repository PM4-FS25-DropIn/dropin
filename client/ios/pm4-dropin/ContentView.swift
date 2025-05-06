//
//  ContentView.swift
//  dropin
//
//  Created by leo on 16.03.2025.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("showOnboarding") private var showOnboarding = true
    @Environment(AuthService.self) private var authService

    var body: some View {
        if showOnboarding {
            OnboardingView(showOnboarding: $showOnboarding)
        } else {
             if authService.isAuthenticated {
                 AppView()
             } else {
                 AuthView()
             }
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthService())
}
