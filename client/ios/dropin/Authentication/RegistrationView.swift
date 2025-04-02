import SwiftUI

struct RegistrationView: View {
    
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
            
            inputSection
            Spacer()
            submitSection
            
            Spacer()
        }
    }
    
    private var inputSection: some View {
        VStack(spacing: 35) {
            Section {
                TextField("Username", text: .constant(""))
                    .roundedTextFieldStyle()
                TextField("Email", text: .constant(""))
                    .roundedTextFieldStyle()
                SecureField("Password", text: .constant(""))
                    .roundedTextFieldStyle()
                SecureField("Confirm Password", text: .constant(""))
                    .roundedTextFieldStyle()
            }
            .padding(.horizontal,35)
        }
    }
    
    private var submitSection: some View {
        VStack(spacing: 30) {
            Button(action: {}) {
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
                NavigationLink(destination: LoginView()) {
                    Text("Log In")
                        .foregroundColor(Color("AccentColor"))
                        .fontWeight(.bold)
                }
            }
        }
    }
    
}


#Preview {
    RegistrationView()
}
