import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var showLoginForm = false
    @State private var showSignupSheet = false
    @State private var localAuthStatus = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("SQuest")
                .font(.funnel(s: 50))
                .foregroundColor(.white)
                .padding(.top, 80)
            
            Image("AppPicture")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
            
            Spacer()
            
            // Welcome Text
            VStack(spacing: 10) {
                Text("Join Us & Explore")
                    .font(.funnel(s: 30))
                    .foregroundColor(.white)
                
                Text("Create an account to start your adventure")
                    .font(.body)
                    .foregroundColor(.gray)
                
                if !authViewModel.verificationMessage.isEmpty {
                    Text(authViewModel.verificationMessage)
                        .font(.body)
                        .foregroundColor(.green)
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Login Form
            if showLoginForm {
                VStack(spacing: 15) {
                    AuthTextField(
                        placeholder: "Email",
                        systemImage: "envelope",
                        isSecure: false,
                        text: $authViewModel.email
                    )
                    .colorScheme(.dark)
                    
                    AuthTextField(
                        placeholder: "Password",
                        systemImage: "lock",
                        isSecure: true,
                        text: $authViewModel.password
                    )
                    .colorScheme(.dark)
                    
                    if !authViewModel.errorMessage.isEmpty {
                        Text(authViewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    Button(action: authViewModel.login) {
                        if authViewModel.isLoading {
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
                    .disabled(authViewModel.isLoading)
                }
                .padding(.top, 20)
                
            }
            
            // Buttons
            VStack(spacing: 15) {
                if !showLoginForm {
                    Button(action: { showLoginForm = true }) {
                        Text("Log In")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                Button(action: { showSignupSheet = true }) {
                    Text("Get Started")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            
        }
        .ignoresSafeArea(.container, edges: .top)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 30/255, green: 30/255, blue: 50/255))
        .sheet(isPresented: $showSignupSheet) {
            SignupView()
                .environmentObject(authViewModel)
        }
        .onChange(of: authViewModel.shouldDismissSignup) { newValue, _ in
            if newValue {
                showSignupSheet = false
                authViewModel.shouldDismissSignup = false
            }
        }
        .onChange(of: authViewModel.isAuthenticated) { newValue, _ in
            localAuthStatus = newValue
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AuthViewModel(userProfile: UserProfile()))
}
