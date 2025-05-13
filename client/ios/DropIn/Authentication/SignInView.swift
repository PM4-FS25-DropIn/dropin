import SwiftUI

struct SignInView: View {
    @Environment(AuthService.self) private var authService
    
    @State private var authData = AuthCredentials()
    @State private var signInState: AsyncStatus = .idle
    @State private var showAlert = false
    @Binding var selectedAuthMode: AuthMode
    
    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            Spacer()
            header
            loginForm
                .alert("Error", isPresented: $showAlert) {
                    Button("Ok", role: .cancel) { }
                } message: {
                    Text(signInState.error)
                }
            Spacer()
            footer
        }
        .padding(30)
    }
    
    private var footer: some View {
        HStack {
            Text("Don't have an account?")
                .foregroundStyle(.secondary)
            Button("Create new one") {
                selectedAuthMode = .signUp
            }
            .foregroundStyle(.accent)
        }
        .font(.footnote)
    }
    
    private var header: some View {
        VStack {
            Text("Welcome back!")
                .font(.title)
                .bold()
                .padding()
            Text("Log in to your existing account.")
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
    }
    
    private var loginForm: some View {
        VStack(spacing: 35) {
            AuthTextField("Email", value: $authData.email)
            AuthSecureField("Password", value: $authData.password)
            
            displayFormError()
            Button {
                signIn()
            } label: {
                Text("Sign in")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 30))
            .controlSize(.large)
            .bold()
            .padding(.top, 40)
            .disabled(signInState.isRunning || !isFormValid())
        }
    }
    
    private func isFormValid() -> Bool {
        if authData.email.isEmpty || authData.password.isEmpty {
            return false
        }
        return true
    }
    
    private func displayFormError() -> some View {
        var show = true
        var message = ""
        if authData.email.isEmpty {
            message = "Email is empty."
        } else if authData.password.isEmpty {
            message = "Password is empty."
        } else {
            show = false
        }
        
        return Text(message)
            .font(.footnote)
            .bold()
            .foregroundStyle(.red)
            .opacity(show ? 1 : 0)
    }
    
    
    private func signIn() {
        Task {
            signInState = .running
            do {
                try await authService.signIn(authData: authData)
                signInState = .success
            } catch {
                signInState = .failure(error)
                showAlert = true
            }
        }
    }
}


#Preview {
    SignInView(selectedAuthMode: .constant(.signIn))
        .environment(AuthService())
}
