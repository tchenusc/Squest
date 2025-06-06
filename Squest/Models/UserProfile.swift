import Foundation
import SwiftUI

class UserProfile: ObservableObject {
    @Published var current_user_id: UUID?
    @Published var email: String
    @Published var isAuthenticated: Bool
    
    init(userId: UUID? = nil, email: String = "", isAuthenticated: Bool = false) {
        self.current_user_id = userId
        self.email = email
        self.isAuthenticated = isAuthenticated
    }
    
    func updateFromAuth(email: String, userId: UUID) {
        self.email = email
        self.current_user_id = userId
        self.isAuthenticated = true
    }
    
    func clear() {
        self.email = ""
        self.current_user_id = nil
        self.isAuthenticated = false
    }
} 