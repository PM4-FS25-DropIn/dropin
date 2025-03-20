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
            HomeView()
        }
    }
}

#Preview {
    ContentView()
}
