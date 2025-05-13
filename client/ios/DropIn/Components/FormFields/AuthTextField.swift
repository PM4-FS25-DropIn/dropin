import SwiftUI

struct AuthTextField: View {
    let placeholder: String
    @Binding var value: String
    
    init(_ placeholder: String, value: Binding<String>) {
        self.placeholder = placeholder
        self._value = value
    }
    
    init(value: Binding<String>) {
        self.placeholder = ""
        self._value = value
    }
    
    var body: some View {
        TextField(placeholder, text: $value)
            .padding()
            .padding(.horizontal, 15.0)
            .overlay(RoundedRectangle(cornerRadius: 30)
                .stroke(.tertiary, lineWidth: 1))
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
    }
}

#Preview {
    AuthTextField("Placeholder", value: .constant(""))
}
