import SwiftUI

/// Options for the DropInsView picker.
private enum EventTabSelection: String, CaseIterable {
    case allEvents = "All DropIns"
    case myEvents = "My DropIns"
}

/// Displays a picker with two views displaying either all joined events or only events created by the user.
struct DropInsView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    @State private var eventTabSelection: EventTabSelection = .allEvents

    var body: some View {
        Picker("DropIn Selection", selection: $eventTabSelection) {
            ForEach(EventTabSelection.allCases, id: \.self) {
                Text($0.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .padding()
        switch eventTabSelection {
        case .allEvents:
            AllEventsList()
        case .myEvents:
            MyEventsList()
        }
    }
    
}

#Preview {
    DropInsView()
        .environment(EventStore())
        .environment(AuthService())
}

