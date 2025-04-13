import SwiftUI

struct AuthTextField: View {
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
        TextField(placeholder, text: value)
            .roundedTextFieldStyle()
    }
}

#Preview {
    AuthTextField("Placeholder", value: .constant(""))
}
