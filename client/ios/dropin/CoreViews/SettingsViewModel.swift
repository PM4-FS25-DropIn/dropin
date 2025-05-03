//
//  SettingsViewModel.swift
//  dropin
//
//  Created on 28/04/2025.
//

import SwiftUI

// MARK: - ViewModel
@MainActor
final class SettingsViewModel: ObservableObject {

    // Account
    @Published var email: String = ""

    // Notifications
    @Published var eventNotificationsEnabled: Bool = true
    @Published var chatNotificationsEnabled: Bool = true

    // Appearance
    enum AppTheme: String, CaseIterable, Identifiable {
        case system, light, dark
        var id: Self { self }
    }
    @Published var selectedTheme: AppTheme = .system

    // MARK: - Account Actions
    func updateEmail() async {
        print("Updating email address")
        try? await Task.sleep(nanoseconds: 500_000_000)
    }

    func updatePassword(oldPassword: String, newPassword: String) async throws {
        // TODO: Implement actual password update logic
        // Simulated validation
        guard !oldPassword.isEmpty else {
            throw NSError(
                domain: "Auth",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Old password is required"
                ]
            )
        }

        guard newPassword.count >= 8 else {
            throw NSError(
                domain: "Auth",
                code: 2,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Password must be at least 8 characters"
                ]
            )
        }

        print("Password updated successfully")
        try await Task.sleep(nanoseconds: 500_000_000)
    }

    // TODO: Implement verification logic and then delete account
    func deleteAccount() async {
        print("Deleting account...")
        try? await Task.sleep(nanoseconds: 500_000_000)
    }

    // TODO: Implement sign out logic
    func signOut() async {
        print("Signing out...")
        try? await Task.sleep(nanoseconds: 200_000_000)
    }
}

// MARK: - Change Password View
struct ChangePasswordView: View {
    @ObservedObject var vm: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var showError = false

    var body: some View {
        Form {
            Section {
                SecureField("Current Password", text: $oldPassword)
                SecureField("New Password", text: $newPassword)
                SecureField("Confirm New Password", text: $confirmPassword)
            }

            Section {
                Button("Change Password") {
                    guard validatePasswords() else { return }

                    Task {
                        do {
                            try await vm.updatePassword(
                                oldPassword: oldPassword,
                                newPassword: newPassword
                            )
                            dismiss()
                        } catch {
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .alert("Password Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func validatePasswords() -> Bool {
        guard !oldPassword.isEmpty else {
            errorMessage = "Please enter your current password"
            showError = true
            return false
        }

        guard !newPassword.isEmpty else {
            errorMessage = "Please enter a new password"
            showError = true
            return false
        }

        let trimmedNewPassword = newPassword.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let trimmedConfirmPassword = confirmPassword.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard trimmedNewPassword == trimmedConfirmPassword else {
            errorMessage = "New passwords don't match"
            showError = true
            return false
        }

        let passwordRegex =
            "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)

        guard predicate.evaluate(with: newPassword) else {
            errorMessage =
                "Password must contain:\n• 8+ characters\n• A number\n• A special character (@$!%*#?&)"
            showError = true
            return false
        }

        return true
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @StateObject private var vm = SettingsViewModel()

    var body: some View {
        NavigationStack {
            List {
                AccountSection(vm: vm)
                NotificationsSection(vm: vm)
                AppearanceSection(vm: vm)
                SupportSection()
                DangerZoneSection(vm: vm)
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(5)
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Sections
private struct AccountSection: View {
    @ObservedObject var vm: SettingsViewModel

    @Environment(AuthService.self) private var authService
    
    @State private var showSignOutAlert = false

    var body: some View {
        Section(header: Text("Account")) {
            
            // TODO Change email logic with verification
            TextField("Email", text: $vm.email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .onSubmit { Task { await vm.updateEmail() } }

            NavigationLink {
                ChangePasswordView(vm: vm)
            } label: {
                Text("Change Password")
            }

            Button {
                showSignOutAlert = true
            } label: {
                Text("Sign Out")
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

private struct NotificationsSection: View {
    @ObservedObject var vm: SettingsViewModel
    var body: some View {
        Section(header: Text("Notifications")) {
            Toggle("Event Notifications", isOn: $vm.eventNotificationsEnabled)
            Toggle("Chat Notifications", isOn: $vm.chatNotificationsEnabled)
        }
    }
}

private struct AppearanceSection: View {
    @ObservedObject var vm: SettingsViewModel
    var body: some View {
        Section(header: Text("Appearance")) {
            Picker("Theme", selection: $vm.selectedTheme) {
                ForEach(SettingsViewModel.AppTheme.allCases) { theme in
                    Text(theme.rawValue.capitalized).tag(theme)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

private struct SupportSection: View {
    var body: some View {
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

private struct DangerZoneSection: View {

    @ObservedObject var vm: SettingsViewModel

    var body: some View {
        Section(header: Text("Danger Zone")) {

            Button(role: .destructive) {
                Task { await vm.deleteAccount() }
            } label: {
                Text("Delete Account")
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .environment(AuthService())
}
