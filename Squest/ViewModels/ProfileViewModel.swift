import SwiftUI
import Combine
import Supabase

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var tempDisplayedName: String = ""
    @Published var tempAvatarImage: UIImage?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var hasUnsavedChanges: Bool = false
    
    private let client = SupabaseManager.shared.client
    let userProfile: UserProfile
    
    init(userProfile: UserProfile) {
        self.userProfile = userProfile
    }
    
    func loadProfileForEditing() {
        tempDisplayedName = userProfile.displayedName ?? ""
        // Note: tempAvatarImage will be loaded when user selects an image
        hasUnsavedChanges = false
        errorMessage = ""
    }
    
    func resetTempState() {
        tempDisplayedName = userProfile.displayedName ?? ""
        tempAvatarImage = nil
        hasUnsavedChanges = false
        errorMessage = ""
    }
    
    func validateForm() -> Bool {
        let trimmedName = tempDisplayedName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            errorMessage = "Display name cannot be empty"
            return false
        }
        
        if trimmedName.count > 50 {
            errorMessage = "Display name must be 50 characters or less"
            return false
        }
        
        return true
    }
    
    func saveProfileChanges() async -> Bool {
        guard validateForm() else { return false }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let trimmedName = tempDisplayedName.trimmingCharacters(in: .whitespacesAndNewlines)
            var newAvatarUrl: String? = userProfile.avatarUrl
            
            // Handle avatar changes
            if tempAvatarImage == nil && userProfile.avatarUrl != nil {
                // User wants to remove avatar
                newAvatarUrl = nil
            } else if let newImage = tempAvatarImage {
                // User selected a new image
                newAvatarUrl = try await uploadAvatar(newImage)
            }
            print("[DEBUG] Calling updateUserProfile with displayedName: \(trimmedName), avatarUrl: \(String(describing: newAvatarUrl))")
            // Update database
            try await updateUserProfile(displayedName: trimmedName, avatarUrl: newAvatarUrl)
            // Reset temporary state
            tempAvatarImage = nil
            hasUnsavedChanges = false
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }

    func updateUserProfile(displayedName: String, avatarUrl: String?) async throws {
        guard let userId = userProfile.current_user_id else {
            throw ProfileError.networkError
        }
        do {
            try await client
                .from("users")
                .update([
                    "displayed_name": displayedName,
                    "avatar_url": avatarUrl
                ])
                .eq("id", value: userId)
                .execute()
            // Update local user profile
            userProfile.updateProfile(displayedName: displayedName, avatarUrl: avatarUrl)
            print("[DEBUG] Database update successful.")
        } catch {
            print("[DEBUG] Database update failed: \(error.localizedDescription)")
            throw ProfileError.databaseUpdateFailed
        }
    }
    
    func uploadAvatar(_ image: UIImage) async throws -> String {
        guard let userId = userProfile.current_user_id else {
            throw ProfileError.networkError
        }
        
        // Validate and crop image if needed
        guard let processedImage = validatedAndCroppedImage(image) else {
            throw ProfileError.imageProcessingFailed
        }
        
        // Compress image
        guard let imageData = compressImage(processedImage) else {
            throw ProfileError.imageProcessingFailed
        }
        
        // Generate unique filename
        let timestamp = Int(Date().timeIntervalSince1970)
        let filename = "\(userId.uuidString.lowercased())/\(timestamp).jpg"
        
        do {
            // Upload to Supabase storage
            try await client.storage
                .from("avatars")
                .upload(
                    filename,
                    data: imageData,
                    options: FileOptions(contentType: "image/jpeg")
                )
            
            // Get public URL
            let publicURL = try client.storage
                .from("avatars")
                .getPublicURL(path: filename)
            
            return publicURL.absoluteString
            
        } catch {
            print("❌ Avatar upload failed: \(error.localizedDescription)")
            throw ProfileError.uploadFailed
        }
    }
} 
