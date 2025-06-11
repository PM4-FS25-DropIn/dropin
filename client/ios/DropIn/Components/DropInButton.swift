//
//  DropInButton.swift
//  dropin
//
//  Created by Moritz Feuchter on 01/05/2025.
//


import SwiftUI

/// A styled button for joining an event.
struct DropInButton: View {
    @Binding var attendanceStatus: AttendanceStatus
    
    var action: () -> Void
    var extended: Bool = false
    
    var body: some View {
        Button {
            action()
        } label: {
            if extended {
                Text(attendanceStatus == .joined ? "Dropped In": "Drop In")
                    .frame(maxWidth: .infinity)
                    .font(.subheadline)
                    .bold()
            } else {
                Text(attendanceStatus == .joined ? "Dropped In": "Drop In")
                    .font(.subheadline)
                    .bold()
            }
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 30))
        .disabled(attendanceStatus == .joined)
    }
}

#Preview {
    DropInButton(attendanceStatus: .constant(.undetermined), action: { print("Running") } )
}
