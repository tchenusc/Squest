import SwiftUI

struct StatView: View {
    let value: String
    let title: String
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.black)
            Text(title)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ActivityRow: View {
    let icon: String
    let title: String
    let time: String
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.yellow)
                .frame(width: 32, height: 32)
                .background(Color(.systemGray6).opacity(0.5))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(.black)
                Text(time)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct InfoBubbleView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your earned coins.")
                .font(.firaSansBold(s: 14))
            +
            Text(" Obtained by completing quests of various types of difficulty.").font(.firaSans(s: 14))
            Text("Rumors say that these are the currency of an up and coming region to be explored.")
                .font(.firaSans(s: 14))
        }
        .foregroundColor(.black)
        .padding()
        .background(Color(red: 0.8, green: 0.7, blue: 0.9))
        .cornerRadius(12)
        .overlay(
            Triangle()
                .fill(Color(red: 0.8, green: 0.7, blue: 0.9))
                .frame(width: 20, height: 10)
                .offset(x: -99, y: -10),
            alignment: .top
        )
        .shadow(radius: 0)
        .frame(maxWidth: 260)
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct BadgeWallView: View {
    struct Badge: Identifiable {
        let id = UUID()
        let name: String
        let imageName: String // Use asset name or URL
        let isCompleted: Bool
    }
    let badges: [Badge]
    let columns = [GridItem(.adaptive(minimum: 60), spacing: 16)]
    @State private var poppedBadgeId: UUID? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wall of Fame")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .padding(.leading, 20)
            // Only the badge grid is inside the border
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(badges) { badge in
                    Button(action: {
                        poppedBadgeId = badge.id
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                            poppedBadgeId = nil
                        }
                        print("Badge tapped: \(badge.name)")
                    }) {
                        VStack(spacing: 6) {
                            ZStack {
                                if badge.isCompleted {
                                    Image(badge.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.yellow, lineWidth: 3))
                                        .shadow(radius: 4)
                                        .scaleEffect(poppedBadgeId == badge.id ? 1.18 : 1.0)
                                        .animation(.spring(response: 0.25, dampingFraction: 0.45, blendDuration: 0.1), value: poppedBadgeId == badge.id)
                                } else {
                                    Image(badge.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2))
                                        .opacity(0.3)
                                        .scaleEffect(poppedBadgeId == badge.id ? 1.18 : 1.0)
                                        .animation(.spring(response: 0.25, dampingFraction: 0.45, blendDuration: 0.1), value: poppedBadgeId == badge.id)
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.gray)
                                        .offset(y: 20)
                                }
                            }
                            Text(badge.name)
                                .font(.caption)
                                .foregroundColor(badge.isCompleted ? .primary : .gray)
                                .lineLimit(1)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 3)
                    .background(Color.white.cornerRadius(20))
            )
            .padding(.horizontal, 10)
        }
    }
} 