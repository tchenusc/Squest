import SwiftUI

struct AuthTextField: View {
    let placeholder: String
    let systemImage: String
    let isSecure: Bool
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.gray)
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textContentType(.password)
            } else {
                TextField(placeholder, text: $text)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
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