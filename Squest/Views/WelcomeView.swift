import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var showLoginForm = false
    @State private var showSignupSheet = false
    @State private var localAuthStatus = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color(red: 30/255, green: 30/255, blue: 50/255)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("SQuest")
                            .font(.largeTitle)
                            .fontWeight(.bold)
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
                                .font(.title)
                                .fontWeight(.bold)
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
                        }
                        
                        // Prevents excessive bottom spacing
                        Spacer().frame(height: 40)
                    }
                    .frame(maxWidth: .infinity)
                    .onChange(of: authViewModel.isAuthenticated) { newValue, _ in
                        localAuthStatus = newValue
                    }
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSignupSheet) {
                SignupView()
                    .environmentObject(authViewModel)
            }
            .onChange(of: authViewModel.shouldDismissSignup) { newValue, _ in
                if newValue {
                    //print("IM CLOSING THE SIGNUP PAGE")
                    showSignupSheet = false
                    authViewModel.shouldDismissSignup = false  // Reset the flag
                }
            }
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AuthViewModel(userProfile: UserProfile()))
}
