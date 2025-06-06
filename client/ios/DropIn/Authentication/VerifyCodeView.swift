import SwiftUI

/// Displays an interface to enter verification code.
struct VerifyCodeView: View {
    var authData: AuthCredentials
    
    @Environment(AuthService.self) private var authService
    @State private var code: String = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Verify your email")
                .font(.system(size: 32))
                .fontWeight(.bold)
                .padding()
            Text("Enter the code you received in your email")
            TextField("Verify code", text: $code)
                .roundedTextFieldStyle()
                .padding()
            Button(action: signUpOTP) {
                Text("Verify")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color("AccentColor"))
                    .cornerRadius(30)
            }
            /*HStack {
                NavigationLink(destination: SignInView()) {
                    Text("Log in")
                        .foregroundColor(Color("AccentColor"))
                        .fontWeight(.bold)
                }
            }*/
        }
        .padding(.horizontal,35)
        
    }
    
    private func signUpOTP() {
        print("Signing up with OTP")
        Task {
            do {
                try await authService.signUpOTP(authData: authData, code: code)
            } catch {
                print(error)
            }
        }
    }
    
}

#Preview {
    let sampleAuthData = AuthCredentials(email: "example@example.com")
    VerifyCodeView(authData: sampleAuthData)
        .environment(AuthService())
}
