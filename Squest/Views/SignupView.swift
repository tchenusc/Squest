import SwiftUI

struct SignupView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack { // Use ZStack for background color
                Color(red: 30/255, green: 30/255, blue: 50/255) // Match WelcomeView background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Logo and Title
                        VStack(spacing: 10) {
                            Image(systemName: "person.badge.plus")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.blue) // Keep the icon color, or change if needed
                            
                            Text("Create Account")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white) // White text for dark background
                            
                            Text("Join us today")
                                .foregroundColor(.gray) // Gray text for subtitle
                        }
                        .padding(.top, 30)
                        
                        // Signup Form
                        VStack(spacing: 15) {
                            AuthTextField(
                                placeholder: "Username",
                                systemImage: "person",
                                isSecure: false,
                                text: $viewModel.username
                            )
                            .colorScheme(.dark) // Ensure text field is dark mode aware
                            
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
                            
                            AuthTextField(
                                placeholder: "Confirm Password",
                                systemImage: "lock",
                                isSecure: true,
                                text: $viewModel.confirmPassword
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
                        
                        // Sign Up Button
                        Button(action: viewModel.signup) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Account")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue) // Primary button color
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .disabled(viewModel.isLoading)
                        
                        // Login Link
                        HStack {
                            Text("Already have an account?")
                                .foregroundColor(.gray) // Gray text
                            
                            Button("Sign In") {
                                dismiss()
                            }
                            .foregroundColor(.blue) // Blue link color
                        }
                        .padding(.top)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarItems(leading: Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .foregroundColor(.gray) // Gray close button
            })
        }
    }
}

#Preview {
    SignupView()
        .environmentObject(AuthViewModel())
} 