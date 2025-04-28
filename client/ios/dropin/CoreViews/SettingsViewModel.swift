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
    
    var body: some View {
        Section(header: Text("Account")) {
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

            Toggle("Two-Factor Authentication", isOn: $vm.isTwoFactorEnabled)
                .onChange(of: vm.isTwoFactorEnabled) { _, _ in Task { await vm.toggleTwoFactor() } }

            Button(role: .destructive) {
                Task { await vm.deleteAccount() }
            } label: {
                Text("Delete Account")
            }

            Button {
                Task { await vm.signOut() }
            } label: {
                Text("Sign Out")
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
            Link("Help & Feedback", destination: URL(string: "mailto:support@example.com")!)
            Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .environment(AuthService())
}
