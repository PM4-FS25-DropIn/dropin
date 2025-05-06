//
//  DropInButton.swift
//  dropin
//
//  Created by Moritz Feuchter on 01/05/2025.
//


import SwiftUI

struct DropInButton: View {
    @Binding var attendanceStatus: AttendanceStatus
    
    var action: () -> Void
    
    var body: some View {
        Button(attendanceStatus == .joined ? "Dropped In" : "Drop In") {
            action()
        }
        .buttonStyle(.borderedProminent)
        .font(.headline)
        .bold()
        .disabled(attendanceStatus == .joined)
    }
}

#Preview {
    DropInButton(attendanceStatus: .constant(.undetermined), action: { print("Running") } )
}