import SwiftUI

struct SignInView: View {
    @Environment(AuthService.self) private var authService
    
    @State private var authDetails = AuthCredentials()
    
    
    
    var body: some View {
        VStack {
            Text("Welcome Back!")
                .font(.system(size: 32))
                .fontWeight(.bold)
                .padding()
            Text("Log in to your existing account")
        }
        Spacer()
        
        inputForm
        Spacer()
        buttonSection
        
        
        Spacer()
    }
    
    private var inputForm: some View {
        VStack(spacing: 35) {
            Section {
                AuthTextField("Email",value: $authDetails.email)
                AuthSecureField("Password",value: $authDetails.password)
            }
            .padding(.horizontal,35)
        }
    }
    
    private var buttonSection: some View {
        VStack() {
            Button(action: signIn) {
                Text("Sign In")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color("AccentColor"))
                    .cornerRadius(30)
            }
            .padding(.horizontal, 35)
        }
    }
    
    private func signIn() {
        Task {
            do {
                try await authService.signIn(authData: authDetails)
            } catch {
                print(error)
            }
        }
    }
}


#Preview {
    SignInView()
        .environment(AuthService())
}
