import SwiftUI
import Combine

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var username = ""
    @Published var isAuthenticated = false
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    func login() {
        isLoading = true
        // TODO: Implement actual authentication logic
        // For now, we'll just simulate a successful login
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.isAuthenticated = true
            print("DEBUG: isAuthenticated set to \(self.isAuthenticated)")
        }
    }
    
    func signup() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        isLoading = true
        // TODO: Implement actual signup logic
        // For now, we'll just simulate a successful signup
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.isAuthenticated = true
        }
    }
    
    func logout() {
        isAuthenticated = false
    }
} 