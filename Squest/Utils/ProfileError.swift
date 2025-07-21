import Foundation

enum ProfileError: Error, LocalizedError {
    case imageProcessingFailed
    case uploadFailed
    case invalidDisplayName
    case networkError
    case databaseUpdateFailed
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process image. Please try again."
        case .uploadFailed:
            return "Failed to upload image. Please check your connection and try again."
        case .invalidDisplayName:
            return "Display name must be between 1 and 50 characters."
        case .networkError:
            return "Network connection error. Please check your internet connection."
        case .databaseUpdateFailed:
            return "Failed to update profile. Please try again."
        }
    }
} 