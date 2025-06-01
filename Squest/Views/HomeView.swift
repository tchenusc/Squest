import SwiftUI

struct Quest: Identifiable {
    let id = UUID()
    let rank: String
    let title: String
    let short_description: String
    let long_description: String
    let duration: String
    let xp: String
    var inProgress: Bool = false
}

// Helper to get color for rank
func colorForRank(_ rank: String) -> Color {
    switch rank.uppercased() {
    case "A":
        return Color(red: 1.0, green: 0.91, blue: 0.91)
    case "B":
        return Color(red: 1.0, green: 0.97, blue: 0.78)
    case "C":
        return Color(red: 0.82, green: 1.0, blue: 0.91)
    case "S":
        return Color(red: 0.85, green: 0.93, blue: 1.0)
    case "S++":
        return Color(red: 0.95, green: 0.85, blue: 1.0)
    case "F":
        return Color(red: 0.95, green: 0.95, blue: 0.95)
    default:
        return Color(.systemGray5)
    }
}

// Helper to get sort value for rank
func rankSortValue(_ rank: String) -> Int {
    switch rank.uppercased() {
    case "S++": return 0
    case "S": return 1
    case "A": return 2
    case "B": return 3
    case "C": return 4
    case "F": return 5
    default: return 6
    }
}

struct HomeView: View {
    @State private var quests: [Quest] = [
        Quest(rank: "C", title: "Morning Meditation", short_description: "Start your day with clarity and purpose", long_description: "Begin your day with 10 minutes of meditation to center yourself, clear your mind, and set intentions for the day ahead. Find a quiet space, sit comfortably, and focus on your breath.", duration: "10 mins", xp: "50 XP"),
        Quest(rank: "B", title: "Nature Explorer", short_description: "Take a walk in nature and document 3 interesting findings", long_description: "Step outside and immerse yourself in nature. Document three interesting plants, animals, or natural phenomena you observe. Take pictures or write descriptions.", duration: "30 mins", xp: "100 XP"),
        Quest(rank: "B", title: "Knowledge Expansion", short_description: "Learn something new and share with a friend", long_description: "Dedicate 45 minutes to learning about a new topic. It could be anything from history to science. Then, share what you learned with a friend or family member.", duration: "45 mins", xp: "120 XP"),
        Quest(rank: "A", title: "Digital Detox", short_description: "Go 3 hours without checking your phone or social media", long_description: "Unplug and disconnect for three consecutive hours. Avoid checking your phone, social media, emails, or any other digital distractions. Engage in a non-digital activity.", duration: "3 hours", xp: "200 XP"),
        Quest(rank: "S", title: "Ultimate Challenge", short_description: "Complete all quests in one day", long_description: "Attempt to complete every available quest within a single 24-hour period. This requires significant planning and dedication.", duration: "5 hours", xp: "500 XP"),
        Quest(rank: "S++", title: "Legendary Feat", short_description: "Achieve the impossible!", long_description: "Complete a hidden legendary quest that is only revealed to those who have achieved S rank on all other quests. The task is unknown until you reach this rank.", duration: "8 hours", xp: "1000 XP"),
        Quest(rank: "F", title: "Failed Quest", short_description: "Try again next time.", long_description: "This quest represents a challenge that was attempted but not completed. Review what went wrong and prepare to try again.", duration: "--", xp: "0 XP")
    ]
    
    @State private var selectedQuestID: UUID? = nil
    @State private var showDetail: Bool = false
    @State private var pressedQuestID: UUID? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top row with title and streak
            HStack {
                // Modern, aesthetic title
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.purple)
                    Text("Squest")
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                        .foregroundColor(.purple)
                }
                
                Spacer()
                
                // Streak display
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("7") // Placeholder streak count
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                }
                .padding(.trailing, 20)
            }
            .padding(.top, 32)
            .padding(.leading, 20)
            .padding(.bottom, 24)
            
            Text("Available Quests")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
            
            ScrollView {
                VStack(spacing: 20) {
                    ForEach($quests.sorted(by: { rankSortValue($0.wrappedValue.rank) < rankSortValue($1.wrappedValue.rank) })) { $quest in
                        Button(action: {
                            selectedQuestID = quest.id
                            showDetail = true
                        }) {
                            HStack(spacing: 0) {
                                VStack(spacing: 0) {
                                    Text(quest.rank)
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundColor(.black)
                                    Text("RANK")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(.black.opacity(0.7))
                                }
                                .frame(width: 60)
                                .frame(maxHeight: .infinity)
                                .background(colorForRank(quest.rank))
                                .cornerRadius(14, corners: [.topLeft, .bottomLeft])
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(quest.title)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.black)
                                    Text(quest.short_description)
                                        .font(.system(size: 15, weight: .regular, design: .rounded))
                                        .foregroundColor(.black.opacity(0.8))
                                    HStack {
                                        Text(quest.duration)
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text(quest.xp)
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundColor(Color.purple)
                                    }
                                }
                                .padding(.vertical, 18)
                                .padding(.horizontal, 16)
                            }
                            .frame(height: 90)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.purple.opacity(0.18), lineWidth: 2)
                            )
                            .shadow(color: pressedQuestID == quest.id ? Color.purple.opacity(0.18) : Color.purple.opacity(0.07), radius: pressedQuestID == quest.id ? 16 : 6, x: 0, y: 2)
                            .scaleEffect(pressedQuestID == quest.id ? 1.03 : 1.0)
                            .padding(.horizontal, 12)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: pressedQuestID == quest.id)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in pressedQuestID = quest.id }
                                .onEnded { _ in pressedQuestID = nil }
                        )
                        #if os(macOS)
                        .onHover { hovering in
                            pressedQuestID = hovering ? quest.id : nil
                        }
                        #endif
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 24)
            }
        }
        .background(Color(.systemGray6).opacity(0.5).ignoresSafeArea())
        .sheet(isPresented: $showDetail) {
            if let index = quests.firstIndex(where: { $0.id == selectedQuestID }) {
                DetailedQuestView(quest: quests[index], inProgress: $quests[index].inProgress) {
                    showDetail = false
                }
            }
        }
    }
}

// Helper for corner radius on specific corners
fileprivate extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

fileprivate struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    HomeView()
} 