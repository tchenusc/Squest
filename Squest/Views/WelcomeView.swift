import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var showLoginView = false
    @State private var showSignupView = false
    
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
            
            // Buttons
            VStack(spacing: 15) {
                Button(action: { showLoginView = true }) {
                    Text("Log In")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Button(action: { showSignupView = true }) {
                    Text("Get Started")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 30/255, green: 30/255, blue: 50/255))
        .fullScreenCover(isPresented: $showLoginView) {
            LoginView()
                .environmentObject(authViewModel)
        }
        .fullScreenCover(isPresented: $showSignupView) {
            SignupView()
                .environmentObject(authViewModel)
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AuthViewModel(userProfile: UserProfile()))
}
