import SwiftUI

class UserProfile: ObservableObject {
    @Published var current_user_id: Int = 1 // Default or temporary ID
    
    init(userId: Int = 1) {
        self.current_user_id = userId
    }
} 
