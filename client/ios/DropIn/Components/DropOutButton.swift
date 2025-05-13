//
//  DropOutButton.swift
//  DropIn
//
//  Created by leo on 13.05.2025.
//

import SwiftUI

struct DropOutButton: View {
    @Binding var attendanceStatus: AttendanceStatus
    
    var action: () -> Void
    
    var body: some View {
        if attendanceStatus == .joined {
            Button {
                action()
            } label: {
                Image(systemName: "figure.walk.departure")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle(radius: 30))
        }
    }
}

#Preview {
    DropOutButton(attendanceStatus: .constant(.undetermined), action: { print("Running") })
}
