//
//  SettingsView.swift
//  dropin
//
//  Created on 08/05/2025.
//

import Observation
import SwiftUI
import Auth

/// Displays information about user account and a support section.
struct AboutView: View {
    @Environment(AuthService.self) private var authService
    @State private var showSignOutAlert = false
    @State private var user: User?
    @State private var username: String?
    
    var body: some View {
        NavigationStack {
            List {
                accountSection
                supportSection
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(5)
            .navigationTitle("About")
            .onAppear {
                Task {
                    if let user = authService.user {
                        self.user = user
                    }
                    username = try await authService.getUsername()
                }
            }
        }
    }
    
    
    private var accountSection: some View {
        Section(header: Text("Account")) {
            if let user = authService.user {
                Group {
                    Text(username ?? "Unknown")
                    Text(user.email ?? "Unknown")
                }
                .foregroundStyle(.secondary)
                .bold()
            }

            Button("Sign Out") {
                showSignOutAlert = true
            }
            .alert("Confirm Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    Task {
                        do {
                            try await authService.signOut()
                        } catch {
                            print(error)
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to sign out from this device?")
            }
        }
    }
    
    private var supportSection: some View {
        Section(header: Text("Support & About")) {
            Link(
                "Help & Feedback",
                destination: URL(string: "mailto:support@example.com")!
            )

            HStack {
                Text("Version")
                Spacer()
                Text(
                    Bundle.main.infoDictionary?["CFBundleShortVersionString"]
                        as? String ?? "1.0"
                )
                .foregroundStyle(.secondary)
            }
        }
    }
}


#Preview {
    AboutView()
        .environment(AuthService())
}
