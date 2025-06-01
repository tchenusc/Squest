import SwiftUI

struct Quest: Identifiable {
    let id = UUID()
    let sidequest_id: Int
    let name: String
    let difficulty: String
    let short_description: String
    let long_description: String
    let estimated_duration: String
    let xp_reward_amount: Int
    let gold_reward_amount: Int
    let badger_img_url: String?
    let banner_img_url: String?
    var inProgress: Bool = false
}

// Helper to get color for difficulty
func colorForDifficulty(_ difficulty: String) -> Color {
    switch difficulty.uppercased() {
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

// Helper to get sort value for difficulty
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

struct HomeView: View {
    @State private var quests: [Quest] = [
        Quest(sidequest_id: 1, name: "Morning Meditation", difficulty: "C", short_description: "Start your day with clarity and purpose", long_description: "Begin your day with 10 minutes of meditation to center yourself, clear your mind, and set intentions for the day ahead. Find a quiet space, sit comfortably, and focus on your breath.", estimated_duration: "10 mins", xp_reward_amount: 50, gold_reward_amount: 10, badger_img_url: nil, banner_img_url: nil),
        Quest(sidequest_id: 2, name: "Nature Explorer", difficulty: "B", short_description: "Take a walk in nature and document 3 interesting findings", long_description: "Step outside and immerse yourself in nature. Document three interesting plants, animals, or natural phenomena you observe. Take pictures or write descriptions.", estimated_duration: "30 mins", xp_reward_amount: 100, gold_reward_amount: 20, badger_img_url: nil, banner_img_url: nil),
        Quest(sidequest_id: 3, name: "Knowledge Expansion", difficulty: "B", short_description: "Learn something new and share with a friend", long_description: "Dedicate 45 minutes to learning about a new topic. It could be anything from history to science. Then, share what you learned with a friend or family member.", estimated_duration: "45 mins", xp_reward_amount: 120, gold_reward_amount: 25, badger_img_url: nil, banner_img_url: nil),
        Quest(sidequest_id: 4, name: "Digital Detox", difficulty: "A", short_description: "Go 3 hours without checking your phone or social media", long_description: "Unplug and disconnect for three consecutive hours. Avoid checking your phone, social media, emails, or any other digital distractions. Engage in a non-digital activity.", estimated_duration: "3 hours", xp_reward_amount: 200, gold_reward_amount: 40, badger_img_url: nil, banner_img_url: nil),
        Quest(sidequest_id: 5, name: "Ultimate Challenge", difficulty: "S", short_description: "Complete all quests in one day", long_description: "Attempt to complete every available quest within a single 24-hour period. This requires significant planning and dedication.", estimated_duration: "5 hours", xp_reward_amount: 500, gold_reward_amount: 100, badger_img_url: nil, banner_img_url: nil),
        Quest(sidequest_id: 6, name: "Legendary Feat", difficulty: "S++", short_description: "Achieve the impossible!", long_description: "Complete a hidden legendary quest that is only revealed to those who have achieved S rank on all other quests. The task is unknown until you reach this rank.", estimated_duration: "8 hours", xp_reward_amount: 1000, gold_reward_amount: 250, badger_img_url: nil, banner_img_url: nil),
        Quest(sidequest_id: 7, name: "Failed Quest", difficulty: "F", short_description: "Try again next time.", long_description: "This quest represents a challenge that was attempted but not completed. Review what went wrong and prepare to try again.", estimated_duration: "--", xp_reward_amount: 0, gold_reward_amount: 0, badger_img_url: nil, banner_img_url: nil)
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
                    ForEach($quests.sorted(by: { quest1, quest2 in
                        let difficultyValue1 = difficultySortValue(quest1.wrappedValue.difficulty)
                        let difficultyValue2 = difficultySortValue(quest2.wrappedValue.difficulty)

                        if difficultyValue1 != difficultyValue2 {
                            return difficultyValue1 < difficultyValue2
                        } else {
                            // If difficulties are the same, sort by xp_reward_amount descending
                            return quest1.wrappedValue.xp_reward_amount > quest2.wrappedValue.xp_reward_amount
                        }
                    })) { $quest in
                        Button(action: {
                            selectedQuestID = quest.id
                            showDetail = true
                        }) {
                            HStack(spacing: 0) {
                                VStack(spacing: 0) {
                                    Text(quest.difficulty)
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundColor(.black)
                                    Text("RANK")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(.black.opacity(0.7))
                                }
                                .frame(width: 60)
                                .frame(maxHeight: .infinity)
                                .background(colorForDifficulty(quest.difficulty))
                                .cornerRadius(14, corners: [.topLeft, .bottomLeft])
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(quest.name)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.black)
                                    Text(quest.short_description)
                                        .font(.system(size: 15, weight: .regular, design: .rounded))
                                        .foregroundColor(.black.opacity(0.8))
                                    HStack {
                                        Text(quest.estimated_duration)
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text("\(quest.xp_reward_amount) XP")
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