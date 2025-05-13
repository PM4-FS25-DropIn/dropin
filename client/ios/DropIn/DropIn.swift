//
//  dropinApp.swift
//  dropin
//
//  Created by leo on 16.03.2025.
//

import SwiftUI

@main
struct DropIn: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    @State private var authService = AuthService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authService)
        }
    }
}
