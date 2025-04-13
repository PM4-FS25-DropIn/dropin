import SwiftUI

struct SignUpView: View {
    @Environment(AuthService.self) private var authService
    
    @State private var authData = AuthCredentials()
    @State private var confirmPassword:String = ""
    @State private var didSignUpFail: Bool = false
    @State private var signUpErrorMessage: Error?
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Sign Up")
                    .font(.system(size: 32))
                    .fontWeight(.bold)
                    .padding()
                Text("Create an account and get started!")
            }
            Spacer()
            
            loginForm
                .alert("Error", isPresented: $didSignUpFail) {
                    Button("Ok", role: .cancel) {}
                } message: {
                    Text(signUpErrorMessage?.localizedDescription ?? "Try again later")
                }
            
            Spacer()
            submitSection
            
            Spacer()
        }
    }
    
    private var loginForm: some View {
        VStack(spacing: 35) {
            Section {
                AuthTextField("Username", value: $authData.username)
                AuthTextField("Email", value: $authData.email)
                AuthSecureField("Password", value: $authData.password)
                AuthSecureField("Confirm Password", value: $confirmPassword)
            }
            .padding(.horizontal,35)
        }
    }
    
    private var submitSection: some View {
        VStack(spacing: 30) {
            Button(action: signUp) {
                Text("Sign Up")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color("AccentColor"))
                    .cornerRadius(30)
            }
            .padding(.horizontal, 35)
            HStack() {
                Text("Already have an account?")
                NavigationLink(destination: SignInView()) {
                    Text("Log In")
                        .foregroundColor(Color("AccentColor"))
                        .fontWeight(.bold)
                }
            }
        }
    }
    
    private func signUp() {
        Task {
            do {
                try await authService.signUp(authData: authData)
            } catch {
                didSignUpFail = true
                signUpErrorMessage = error
            }
        }
    }
    
}


#Preview {
    SignUpView()
        .environment(AuthService())
}
