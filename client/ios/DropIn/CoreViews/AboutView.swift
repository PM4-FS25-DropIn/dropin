//
//  SettingsView.swift
//  dropin
//
//  Created on 08/05/2025.
//

import Observation
import SwiftUI

struct AboutView: View {
    @State private var vm = SettingsViewModel()

    var body: some View {
        NavigationStack {
            List {
                AccountSection(vm: vm)
                SupportSection()
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(5)
            .navigationTitle("About")
        }
    }
}


// MARK: - Sections

private struct AccountSection: View {
    @Bindable var vm: SettingsViewModel
    @Environment(AuthService.self) private var authService
    @State private var showSignOutAlert = false

    var body: some View {
        Section(header: Text("Account")) {
            TextField("Email", text: $vm.email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .onSubmit { Task { await vm.updateEmail() } }

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
}

private struct SupportSection: View {
    var body: some View {
        Section(header: Text("Support & About")) {
            Link(
                // TODO: correct email address
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
