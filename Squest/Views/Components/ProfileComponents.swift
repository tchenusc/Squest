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
    let columns = [GridItem(.adaptive(minimum: 80, maximum: 80), spacing: 4)] // Four per line, minimal spacing
    @State private var poppedBadgeId: UUID? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wall of Fame")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .padding(.leading, 20)
            // Only the badge grid is inside the border
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(badges) { badge in
                    Button(action: {
                        poppedBadgeId = badge.id
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
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
                                        .frame(width: 80, height: 80)
                                        .shadow(color: poppedBadgeId == badge.id ? Color.purple.opacity(0.25) : Color.black.opacity(0.08), radius: poppedBadgeId == badge.id ? 16 : 6, x: 0, y: 2)
                                        .scaleEffect(poppedBadgeId == badge.id ? 1.22 : 1.0)
                                        .animation(.spring(response: 0.32, dampingFraction: 0.65, blendDuration: 0.12), value: poppedBadgeId == badge.id)
                                } else {
                                    Image(badge.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .opacity(0.18)
                                        .shadow(color: poppedBadgeId == badge.id ? Color.purple.opacity(0.18) : Color.black.opacity(0.08), radius: poppedBadgeId == badge.id ? 12 : 6, x: 0, y: 2)
                                        .scaleEffect(poppedBadgeId == badge.id ? 1.22 : 1.0)
                                        .animation(.spring(response: 0.32, dampingFraction: 0.65, blendDuration: 0.12), value: poppedBadgeId == badge.id)
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(Color.gray.opacity(0.7))
                                        .offset(y: 20)
                                }
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.vertical, 16)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.white, Color(.systemGray6)]), startPoint: .top, endPoint: .bottom)
                    .cornerRadius(28)
                    .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color(red: 0.15, green: 0.15, blue: 0.18), lineWidth: 1.2)
            )
            .padding(.horizontal, 10)
        }
    }
}

struct CoinDisplayView: View {
    let coins: Int
    let onTap: () -> Void
    @Binding var isPressed: Bool
    @Binding var shouldAnimateOnDismiss: Bool
    @Binding var coinHStackFrame: CGRect
    
    var body: some View {
        HStack {
            HStack {
                Image("CoinPouch")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                Text("\(coins)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            .background(GeometryReader { geometry in
                Color.clear.onAppear {
                    coinHStackFrame = geometry.frame(in: .global)
                }
            })
            .scaleEffect(isPressed || shouldAnimateOnDismiss ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.2), value: isPressed)
            .animation(.easeOut(duration: 0.2), value: shouldAnimateOnDismiss)
            .onTapGesture {
                onTap()
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isPressed = false
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
} 

struct ProfileHeaderView: View {
    let displayedName: String?
    let username: String?
    let avatarUrl: String?
    @ObservedObject var imageLoader: ImageLoader
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                if let image = imageLoader.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                }
            }
            VStack(spacing: 4) {
                Text(displayedName ?? "User")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                Text("@\(username ?? "user")")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 50)
        .padding(.bottom, 24)
        .background(Color(.systemGray6).opacity(0.5))
        .onAppear {
            imageLoader.preload(from: URL(string: avatarUrl ?? ""))
        }
        .onChange(of: avatarUrl) { _, newUrl in
            imageLoader.preload(from: URL(string: newUrl ?? ""))
        }
    }
} 

struct LevelProgressView: View {
    let levelLabel: String
    let levelProgress: CGFloat
    let levelProgressText: String
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Level Progress")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                Spacer()
                Text(levelLabel)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.49, green: 0.4, blue: 0.82))
                    .cornerRadius(12)
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 12)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0.49, green: 0.4, blue: 0.82))
                        .frame(width: geometry.size.width * levelProgress, height: 12)
                }
            }
            .frame(height: 12)
            Text(levelProgressText)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
} 

struct StatsGridView: View {
    let stats: [(value: String, title: String)]
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.black)
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                ForEach(stats, id: \.title) { stat in
                    StatView(value: stat.value, title: stat.title)
                }
            }
        }
        .padding(.horizontal, 20)
    }
} 

struct TopRightButtonsView: View {
    let userProfile: UserProfile
    var body: some View {
        HStack(spacing: 8) {
            NavigationLink(destination: EditProfileView(userProfile: userProfile)) {
                Image(systemName: "pencil")
                    .font(.system(size: 24))
                    .foregroundColor(.black)
            }
            NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.black)
            }
        }
        .padding(.top, 8)
        .padding(.trailing, 20)
    }
} 
