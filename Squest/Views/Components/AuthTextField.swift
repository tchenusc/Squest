import SwiftUI

struct AuthTextField: View {
    let placeholder: String
    let systemImage: String
    let isSecure: Bool
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.gray)
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textContentType(.password)
                    .focused($isFocused)
            } else {
                TextField(placeholder, text: $text)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .focused($isFocused)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isFocused ? Color.blue : Color.clear, lineWidth: 2)
        )
        .padding(.horizontal)
    }
}

#Preview {
    AuthTextField(
        placeholder: "Email",
        systemImage: "envelope",
        isSecure: false,
        text: .constant("")
    )
} 