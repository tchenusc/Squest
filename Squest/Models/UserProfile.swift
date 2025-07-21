import Foundation
import SwiftUI
import Supabase

class UserProfile: ObservableObject {
    @Published var current_user_id: UUID?
    @Published var email: String
    @Published var displayedName: String?
    @Published var username: String?
    @Published var avatarUrl: String?
    @Published var isAuthenticated: Bool
    
    init(userId: UUID? = nil, email: String = "", displayedName: String? = nil, username: String? = nil, avatarUrl: String? = nil, isAuthenticated: Bool = false) {
        self.current_user_id = userId
        self.email = email
        self.displayedName = displayedName
        self.username = username
        self.avatarUrl = avatarUrl
        self.isAuthenticated = isAuthenticated
    }
    
    func updateFromAuth(email: String, userId: UUID, userMetadata: [String: Any]?) {
        self.email = email
        self.current_user_id = userId
        self.isAuthenticated = true
        if let metadata = userMetadata as? [String: AnyJSON] {
            // self.displayedName = metadata["displayed_name"]?.stringValue
            self.username = metadata["username"]?.stringValue
            //self.avatarUrl = metadata["avatar_url"]?.stringValue

            //print("✅ displayedName:", self.displayedName ?? "nil")
            //print("✅ username:", self.username ?? "nil")
            //print("✅ avatarUrl:", self.avatarUrl ?? "nil")
        } else {
            print("❌ updating from auth")
        }
    }
    
    func updateProfile(displayedName: String?, avatarUrl: String?) {
        self.displayedName = displayedName
        self.avatarUrl = avatarUrl
    }
    
    func clear() {
        self.email = ""
        self.current_user_id = nil
        self.displayedName = nil
        self.username = nil
        self.avatarUrl = nil
        self.isAuthenticated = false
    }
} 
