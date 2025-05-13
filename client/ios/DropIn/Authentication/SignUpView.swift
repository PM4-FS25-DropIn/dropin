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
                
            displayFormError()
            Button {
                signUp()
            } label: {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 30))
            .controlSize(.large)
            .bold()
            .padding(.top, 40)
            .disabled(signUpState.isRunning || !isFormValid())
        }
    }
    
    private func isFormValid() -> Bool {
        if authData.username.isEmpty || authData.email.isEmpty || authData.password.isEmpty || authData.confirmPassword.isEmpty  {
            return false
        } else if authData.password != authData.confirmPassword {
            return false
        } else if authData.password.count < 6 {
            return false
        }
        return true
    }
    
    private func displayFormError() -> some View {
        var show = true
        var message = ""
        if authData.username.isEmpty {
            message = "Username is empty."
        } else if authData.email.isEmpty {
            message = "Email is empty."
        } else if authData.password.isEmpty {
            message = "Password is empty."
        } else if authData.confirmPassword.isEmpty {
            message = "Please confirm password."
        } else if authData.password != authData.confirmPassword {
            message = "Passwords don't match."
        } else if authData.password.count < 6 {
            message = "Password should be at least 6 characters."
        } else {
            show = false
        }
        
        return Text(message)
            .font(.footnote)
            .bold()
            .foregroundStyle(.red)
            .opacity(show ? 1 : 0)
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
