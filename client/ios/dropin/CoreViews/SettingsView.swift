//
//  SettingsView.swift
//  dropin
//
//  Created on 08/05/2025.
//

import SwiftUI
import Observation

struct SettingsView: View {
    @State private var vm = SettingsViewModel()

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
