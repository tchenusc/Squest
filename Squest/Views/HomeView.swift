import SwiftUI

struct Quest: Identifiable {
    let id = UUID()
    let rank: String
    let rankColor: Color
    let title: String
    let description: String
    let duration: String
    let xp: String
}

let quests: [Quest] = [
    Quest(rank: "C", rankColor: Color(red: 0.82, green: 1.0, blue: 0.91), title: "Morning Meditation", description: "Start your day with clarity and purpose", duration: "10 mins", xp: "50 XP"),
    Quest(rank: "B", rankColor: Color(red: 1.0, green: 0.97, blue: 0.78), title: "Nature Explorer", description: "Take a walk in nature and document 3 interesting findings", duration: "30 mins", xp: "100 XP"),
    Quest(rank: "B", rankColor: Color(red: 1.0, green: 0.97, blue: 0.78), title: "Knowledge Expansion", description: "Learn something new and share with a friend", duration: "45 mins", xp: "120 XP"),
    Quest(rank: "A", rankColor: Color(red: 1.0, green: 0.91, blue: 0.91), title: "Digital Detox", description: "Go 3 hours without checking your phone or social media", duration: "3 hours", xp: "200 XP")
]

struct HomeView: View {
    @State private var selectedQuest: Quest? = nil
    @State private var showDetail: Bool = false
    @State private var pressedQuestID: UUID? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Available Quests")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .padding(.top, 24)
                .padding(.horizontal, 20)
            
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(quests) { quest in
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
                                .background(quest.rankColor)
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