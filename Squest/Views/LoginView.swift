import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 30/255, green: 30/255, blue: 50/255)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Logo and Title
                        VStack(spacing: 10) {
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.blue)
                            
                            Text("Welcome Back")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Sign in to continue")
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 30)
                        
                        // Login Form
                        VStack(spacing: 15) {
                            AuthTextField(
                                placeholder: "Email",
                                systemImage: "envelope",
                                isSecure: false,
                                text: $viewModel.email
                            )
                            .colorScheme(.dark)
                            
                            AuthTextField(
                                placeholder: "Password",
                                systemImage: "lock",
                                isSecure: true,
                                text: $viewModel.password
                            )
                            .colorScheme(.dark)
                        }
                        .padding(.top, 30)
                        
                        // Error Message
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        // Login Button
                        Button(action: viewModel.login) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign In")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        .disabled(viewModel.isLoading)
                        
                        // Sign Up Link
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.gray)
                            
                            Button("Sign Up") {
                                dismiss()
                            }
                            .foregroundColor(.blue)
                        }
                        .padding(.top)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarItems(leading: Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
                    .padding(8)
                    .contentShape(Rectangle())
            })
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel(userProfile: UserProfile()))
} 