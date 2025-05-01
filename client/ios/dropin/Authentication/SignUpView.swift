import SwiftUI

struct SignUpView: View {
    @Environment(AuthService.self) private var authService
    
    @Binding var selectedAuthMode: AuthMode
    @State private var authData = AuthCredentials()
    @State private var isSignedUp: Bool = false
    @State private var signUpState: AsyncStatus = .idle
    @State private var showAlert = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            Spacer()
            header
            signUpForm
                .alert("Error", isPresented: $showAlert) {
                    Button("Ok", role: .cancel) { }
                } message: {
                    Text(signUpState.error)
                }
            Spacer()
            footer
        }
        .padding(30)
    }
    
    private var footer: some View {
        HStack {
            Text("Already have an account?")
                .foregroundStyle(.secondary)
            Button("Sign In") {
                selectedAuthMode = .signIn
            }
            .foregroundStyle(.accent)
        }
        .font(.footnote)
    }
    
    private var header: some View {
        VStack {
            Text("Sign Up")
                .font(.title)
                .bold()
                .padding()
            Text("Create an account to get started!")
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
    }
    
    private var signUpForm: some View {
        VStack(spacing: 35) {
            AuthTextField("Username", value: $authData.username)
            AuthTextField("Email", value: $authData.email)
            AuthSecureField("Password", value: $authData.password)
            AuthSecureField("Confirm Password", value: $authData.confirmPassword)
            Button {
                signUp()
            } label: {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.primary)
            .controlSize(.large)
            .bold()
            .padding(.top, 40)
            .disabled(signUpState.isRunning)
        }
    }
    
    private func signUp() {
        print("Signing up...")
        Task {
            signUpState = .running
            do {
                try await authService.signUp(authData: authData)
                isSignedUp = true
                signUpState = .success
            } catch {
                signUpState = .failure(error)
                showAlert = true
            }
        }
    }
}

#Preview {
    SignUpView(selectedAuthMode: .constant(.signUp))
        .environment(AuthService())
}
