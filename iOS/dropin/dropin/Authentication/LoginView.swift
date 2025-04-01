//
//  LoginView.swift
//  dropin
//
//  Created by Shpetim Veseli on 28.03.2025.
//

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
        
        VStack(spacing: 35) {
            Section {
                TextField("Email", text: .constant(""))
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color(red: 227/255, green: 227/255, blue: 227/255)))
                SecureField("Password", text: .constant(""))
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color(red: 227/255, green: 227/255, blue: 227/255)))
            }
            .padding(.horizontal,35)
        }
        
        Spacer()
        
        VStack() {
            Button(action: {}) {
                Text("Sign In")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(red: 0/255, green: 180/255, blue: 216/255))
                    .cornerRadius(30)
            }
            .padding(.horizontal, 35)
        }
        
        Spacer()
    }
}


#Preview {
    LoginView()
}
