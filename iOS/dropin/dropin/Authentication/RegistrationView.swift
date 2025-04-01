//
//  RegistrationView.swift
//  dropin
//
//  Created by Shpetim Veseli on 28.03.2025.
//

import SwiftUI

struct RegistrationView: View {
    
    @State private var privacyPolicy: Bool = false
    
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
            
            VStack(spacing: 35) {
                Section {
                    TextField("Username", text: .constant(""))
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color(red: 227/255, green: 227/255, blue: 227/255)))
                    TextField("Email", text: .constant(""))
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color(red: 227/255, green: 227/255, blue: 227/255)))
                    SecureField("Password", text: .constant(""))
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color(red: 227/255, green: 227/255, blue: 227/255)))
                    SecureField("Confirm Password", text: .constant(""))
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color(red: 227/255, green: 227/255, blue: 227/255)))
                }
                .padding(.horizontal,35)
            }
            
            
            Spacer()
            
            VStack(spacing: 30) {
                Button(action: {}) {
                    Text("Sign Up")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(red: 0/255, green: 180/255, blue: 216/255))
                        .cornerRadius(30)
                }
                .padding(.horizontal, 35)
                HStack() {
                    Text("Already have an account?")
                    NavigationLink(destination: LoginView()) {
                        Text("Log In")
                            .foregroundColor(Color(red: 0/255, green: 180/255, blue: 216/255))
                            .fontWeight(.bold)
                    }
                }
            }
            
            
            
            Spacer()
        }
    }
}


#Preview {
    RegistrationView()
}
