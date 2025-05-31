import SwiftUI

struct Quest: Identifiable {
    let id = UUID()
    let rank: String
    let title: String
    let description: String
    let duration: String
    let xp: String
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

let quests: [Quest] = [
    Quest(rank: "C", title: "Morning Meditation", description: "Start your day with clarity and purpose", duration: "10 mins", xp: "50 XP"),
    Quest(rank: "B", title: "Nature Explorer", description: "Take a walk in nature and document 3 interesting findings", duration: "30 mins", xp: "100 XP"),
    Quest(rank: "B", title: "Knowledge Expansion", description: "Learn something new and share with a friend", duration: "45 mins", xp: "120 XP"),
    Quest(rank: "A", title: "Digital Detox", description: "Go 3 hours without checking your phone or social media", duration: "3 hours", xp: "200 XP"),
    Quest(rank: "S", title: "Ultimate Challenge", description: "Complete all quests in one day", duration: "5 hours", xp: "500 XP"),
    Quest(rank: "S++", title: "Legendary Feat", description: "Achieve the impossible!", duration: "8 hours", xp: "1000 XP"),
    Quest(rank: "F", title: "Failed Quest", description: "Try again next time.", duration: "--", xp: "0 XP")
]

struct HomeView: View {
    @State private var selectedQuest: Quest? = nil
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
                    ForEach(quests.sorted { rankSortValue($0.rank) < rankSortValue($1.rank) }) { quest in
                        Button(action: {
                            selectedQuest = quest
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
                                    Text(quest.description)
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
            if let quest = selectedQuest {
                DetailedQuestView(quest: quest) {
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