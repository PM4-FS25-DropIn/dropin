import SwiftUI

struct AuthSecureField: View {
    let placeholder: String
    var value: Binding<String>
    
    init(_ placeholder: String, value: Binding<String>) {
        self.placeholder = placeholder
        self.value = value
    }
    
    init(value: Binding<String>) {
        self.placeholder = ""
        self.value = value
    }
    
    var body: some View {
        SecureField(placeholder, text: value)
            .padding()
            .padding(.horizontal, 15.0)
            .overlay(RoundedRectangle(cornerRadius: 30)
                .stroke(.tertiary, lineWidth: 1))
    }
}

#Preview {
    AuthSecureField("Placeholder", value: .constant(""))
}
