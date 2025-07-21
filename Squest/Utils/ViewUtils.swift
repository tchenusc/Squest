import SwiftUI
import UIKit
import Supabase

func colorForDifficulty(_ difficulty: String) -> Color {
    switch difficulty.uppercased() {
    case "A": return Color(red: 1.0, green: 0.75, blue: 0.75)
    case "B": return Color(red: 1.0, green: 0.97, blue: 0.78)
    case "C": return Color(red: 0.82, green: 1.0, blue: 0.91)
    case "S": return Color(red: 0.85, green: 0.93, blue: 1.0)
    case "S++": return Color(red: 0.95, green: 0.85, blue: 1.0)
    case "F": return Color(red: 0.95, green: 0.95, blue: 0.95)
    default: return Color(.systemGray5)
    }
}

func difficultySortValue(_ difficulty: String) -> Int {
    switch difficulty.uppercased() {
    case "S++": return 0
    case "S": return 1
    case "A": return 2
    case "B": return 3
    case "C": return 4
    case "F": return 5
    default: return 6
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
} 

// MARK: - Image Utilities

func loadImageFromURL(_ urlString: String) async -> UIImage? {
    guard let url = URL(string: urlString) else { return nil }
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        return UIImage(data: data)
    } catch {
        print("❌ Failed to load image from URL: \(error.localizedDescription)")
        return nil
    }
}

func compressImage(_ image: UIImage, maxSize: Int = 10 * 1024 * 1024) -> Data? {
    var compression: CGFloat = 1.0
    var imageData = image.jpegData(compressionQuality: compression)
    if imageData == nil {
        print("[DEBUG] compressImage: Failed to convert image to JPEG data.")
        return nil
    }
    while let data = imageData, data.count > maxSize && compression > 0.1 {
        compression -= 0.1
        print("[DEBUG] compressImage: Compressing, quality=", compression, "size=", data.count)
        imageData = image.jpegData(compressionQuality: compression)
    }
    if let data = imageData, data.count > maxSize {
        print("[DEBUG] compressImage: Unable to compress image below max size (", data.count, "bytes)")
        return nil
    }
    print("[DEBUG] compressImage: Compression successful, final size=", imageData?.count ?? 0)
    return imageData
}

func validateImage(_ image: UIImage) -> Bool {
    // Check file size (max 10MB)
    guard let imageData = image.jpegData(compressionQuality: 1.0) else {
        print("[DEBUG] validateImage: Failed to convert image to JPEG data.")
        return false
    }
    if imageData.count > 10 * 1024 * 1024 {
        print("[DEBUG] validateImage: Image file size too large (", imageData.count, "bytes)")
        return false
    }
    // Check dimensions (max 2048x2048)
    let maxDimension: CGFloat = 2048
    if image.size.width > maxDimension || image.size.height > maxDimension {
        print("[DEBUG] validateImage: Image dimensions too large (", image.size.width, "x", image.size.height, ")")
        return false
    }
    print("[DEBUG] validateImage: Image is valid.")
    return true
}

func validatedAndCroppedImage(_ image: UIImage, maxDimension: CGFloat = 2048, maxSize: Int = 10 * 1024 * 1024) -> UIImage? {
    var workingImage = image
    // Crop if needed
    if image.size.width > maxDimension || image.size.height > maxDimension {
        let side = min(image.size.width, image.size.height, maxDimension)
        let originX = (image.size.width - side) / 2.0
        let originY = (image.size.height - side) / 2.0
        let cropRect = CGRect(x: originX, y: originY, width: side, height: side)
        if let cgImage = image.cgImage?.cropping(to: cropRect) {
            workingImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
            print("[DEBUG] validatedAndCroppedImage: Cropped image to centered square of size \(side)x\(side)")
        } else {
            print("[DEBUG] validatedAndCroppedImage: Failed to crop image.")
            return nil
        }
    }
    // Validate file size
    guard let imageData = workingImage.jpegData(compressionQuality: 1.0) else {
        print("[DEBUG] validatedAndCroppedImage: Failed to convert image to JPEG data.")
        return nil
    }
    if imageData.count > maxSize {
        print("[DEBUG] validatedAndCroppedImage: Image file size too large after cropping (", imageData.count, "bytes)")
        return nil
    }
    print("[DEBUG] validatedAndCroppedImage: Image is valid and within size limits.")
    return workingImage
}

struct UsernameCheck: Decodable {
    let id: UUID
}

func isUsernameAvailable(username: String) async -> Bool {
    let client = SupabaseManager.shared.client
    let lowercaseUsername = username.lowercased()

    do {
        let result: [UsernameCheck] = try await client
            .from("users")
            .select("id")
            .eq("username", value: lowercaseUsername)
            .limit(1)
            .execute()
            .value
        return result.isEmpty
    } catch {
        print("❌ Username check failed: \(error.localizedDescription)")
        return false
    }
}
