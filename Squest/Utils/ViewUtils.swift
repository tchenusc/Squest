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
