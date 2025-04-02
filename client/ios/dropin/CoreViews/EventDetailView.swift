//
//  EventDetailView.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

import SwiftUI

struct EventDetailView: View {
    var event: DropInEvent
    
    var body: some View {
        ScrollView {
            Image(event.imagePaths![0])
                .resizable()
                .scaledToFill()
                .containerRelativeFrame(.vertical, count: 12, span: 4, spacing: 0)
                .clipped()
            Text(event.title)
                .font(.title)
                .bold()
            Text(event.description)
                .font(.subheadline)
            buttonGroup
            EventQuickInfo(event: event)
                .padding()
            Spacer()
        }
    }
    
    private var buttonGroup: some View {
        HStack {
            Button {
                // TODO: Drop In Action
            } label: {
                Text("Drop In")
                    .frame(maxWidth: .infinity)
                    .bold()
            }
            .buttonStyle(.borderedProminent)
            Button {
                // TODO: Not Going Action
            } label: {
                Text("Not Going")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .foregroundStyle(.secondary)
        }
        .padding()
    }
    
   
}

#Preview {
    EventDetailView(event: dummyEvent)
}
