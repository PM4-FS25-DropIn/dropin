import SwiftUI

enum EventTabSelection: String, CaseIterable {
    case allEvents = "All Events"
    case myEvents = "My Events"
}

struct DropInsView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    @State private var eventTabSelection: EventTabSelection = .allEvents

    var body: some View {
        NavigationStack {
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
        .searchable(text: $searchText)
    }
    
}

#Preview {
    DropInsView()
        .environment(EventStore())
}

