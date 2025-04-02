//
//  ContentView.swift
//  dropin
//
//  Created by leo on 16.03.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var showOnboarding = true

    var body: some View {
        if showOnboarding {
            OnboardingView(showOnboarding: $showOnboarding)
        } else {
            /* If user is signed in (check with supabase) then
             if authService.isAuthenticated {
                 AppView()
             } else {
                 LoginView()
             }
             */
            RegistrationView()
        }
    }
}

#Preview {
    ContentView()
}
