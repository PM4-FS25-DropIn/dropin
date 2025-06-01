//
//  AuthView.swift
//  dropin
//
//  Created by leo on 01.05.2025.
//

import SwiftUI

/// Authentication wrapper view for SignIn and SignUp.
struct AuthView: View {
    @State private var selectedAuthMode: AuthMode = .signUp
    
    var body: some View {
        if selectedAuthMode == .signIn {
            SignInView(selectedAuthMode: $selectedAuthMode)
        } else {
            SignUpView(selectedAuthMode: $selectedAuthMode)
        }
    }
}

#Preview {
    AuthView()
        .environment(AuthService())
}
