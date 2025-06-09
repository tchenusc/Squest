import Foundation
import SwiftUI

class UserProfile: ObservableObject {
    @Published var current_user_id: UUID?
    @Published var email: String
    @Published var displayedName: String?
    @Published var username: String?
    @Published var isAuthenticated: Bool
    
    init(userId: UUID? = nil, email: String = "", displayedName: String? = nil, username: String? = nil, isAuthenticated: Bool = false) {
        self.current_user_id = userId
        self.email = email
        self.displayedName = displayedName
        self.username = username
        self.isAuthenticated = isAuthenticated
    }
    
    func updateFromAuth(email: String, userId: UUID, userMetadata: [String: Any]?) {
        self.email = email
        self.current_user_id = userId
        self.isAuthenticated = true
        self.displayedName = userMetadata?["displayed_name"] as? String
        self.username = userMetadata?["username"] as? String
    }
    
    func clear() {
        self.email = ""
        self.current_user_id = nil
        self.displayedName = nil
        self.username = nil
        self.isAuthenticated = false
    }
} 