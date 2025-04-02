import SwiftUI

struct LoginView: View {
    
    var body: some View {
        VStack {
            Text("Welcome Back!")
                .font(.system(size: 32))
                .fontWeight(.bold)
                .padding()
            Text("Log in to your existing account")
        }
        Spacer()
        
        inputSection
        Spacer()
        buttonSection
        
        
        Spacer()
    }
    
    private var inputSection: some View {
        VStack(spacing: 35) {
            Section {
                TextField("Email", text: .constant(""))
                    .roundedTextFieldStyle()
                SecureField("Password", text: .constant(""))
                    .roundedTextFieldStyle()
            }
            .padding(.horizontal,35)
        }
    }
    
    private var buttonSection: some View {
        VStack() {
            Button(action: {}) {
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
}


#Preview {
    LoginView()
}
