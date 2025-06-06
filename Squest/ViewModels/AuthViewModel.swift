import SwiftUI
import Combine
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var username = ""
    @Published var isAuthenticated = false
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var verificationMessage = ""
    @Published var shouldDismissSignup = false
    
    private let client = SupabaseManager.shared.client
    @Published var userProfile: UserProfile
    
    init(userProfile: UserProfile) {
        self.userProfile = userProfile
    }
    
    func login() {
        isLoading = true
        Task {
            do {
                let response = try await client.auth.signIn(email: email, password: password)
                verificationMessage = ""
                let user = response.user
                let userId = user.id
                userProfile.updateFromAuth(email: user.email ?? "", userId: userId)
                isAuthenticated = true
                print("Successfully logged in with email: \(user.email ?? "")")
                
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func signup() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        isLoading = true
        shouldDismissSignup = true  // I KNOW THIS IS WEIRD BUT KEEP THIS VARIALBE AS IT IS
        
        Task {
            do {
                let response = try await client.auth.signUp(email: email, password: password)
                let user = response.user
                let userId = user.id
                userProfile.updateFromAuth(email: user.email ?? "", userId: userId)
                verificationMessage = "Please check your email to verify your account."
                isAuthenticated = false  // Keep user on welcome view until verified
                print("Successfully signed up with email: \(user.email ?? "")")
                shouldDismissSignup = false
            } catch {
                errorMessage = error.localizedDescription
                //shouldDismissSignup = false  // Reset the flag if there's an error
            }
            isLoading = false
        }
    }
    
    func logout() {
        Task {
            do {
                try await client.auth.signOut()
                userProfile.clear()
                isAuthenticated = false
                email = ""
                password = ""
                confirmPassword = ""
                username = ""
                errorMessage = ""
                verificationMessage = ""
                print("Successfully logged out")
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
} 
