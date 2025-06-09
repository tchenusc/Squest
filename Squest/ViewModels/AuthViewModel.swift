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
    
    // AppStorage for persisting session tokens
    @AppStorage("access_token") private var accessToken: String = "" // Changed to String? to allow nil for clearing
    @AppStorage("refresh_token") private var refreshToken: String = ""
    
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
                
                // Store tokens in AppStorage after successful login
                self.accessToken = response.accessToken
                self.refreshToken = response.refreshToken
                print("Session tokens saved to AppStorage after login.")
                
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
        shouldDismissSignup = true
        
        Task {
            do {
                let response = try await client.auth.signUp(email: email, password: password)
                let user = response.user
                let userId = user.id
                userProfile.updateFromAuth(email: user.email ?? "", userId: userId)
                verificationMessage = "Account Created!"
                isAuthenticated = false
                print("Successfully signed up with email: \(user.email ?? "")")
                shouldDismissSignup = false
                
                // Store tokens in AppStorage after successful signup
                if let session = response.session {
                    self.accessToken = session.accessToken
                    self.refreshToken = session.refreshToken
                    print("Session tokens saved to AppStorage after signup.")
                }
                
            } catch {
                errorMessage = error.localizedDescription
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
                
                // Clear tokens from AppStorage on logout
                self.accessToken = ""
                self.refreshToken = ""
                print("Session tokens cleared from AppStorage.")
                
                print("Successfully logged out")
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Session Management
    
    /// Restores the user session from AppStorage if tokens are available.
    /// Call this method from your `@main` App struct or on the welcome screen's `.onAppear`.
    func restoreSession() {
        Task {
            do {
                // Check that tokens exist
                guard !accessToken.isEmpty, !refreshToken.isEmpty else {
                    print("No session tokens found in AppStorage. User is not authenticated.")
                    isAuthenticated = false
                    return
                }

                print("Attempting to restore session from AppStorage...")

                // Restore the Supabase session
                let session = try await client.auth.setSession(
                    accessToken: accessToken,
                    refreshToken: refreshToken
                )

                // Update user state
                let user = session.user
                let userId = user.id
                userProfile.updateFromAuth(email: user.email ?? "", userId: userId)
                isAuthenticated = true
                print("Session successfully restored for user: \(user.email ?? "")")

            } catch {
                print("Error restoring session from AppStorage: \(error.localizedDescription)")
                isAuthenticated = false
            }
        }
    }
}
