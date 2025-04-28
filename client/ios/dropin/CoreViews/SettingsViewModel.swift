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
