import SwiftUI

/// A row view component that displays a single quest with its details and interactive states
struct QuestRowView: View {
    // MARK: - Properties
    let quest: Quest
    let inProgressQuestId: Int64
    let isPressed: Bool
    let onTap: () -> Void
    
    // MARK: - Body
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    Text(quest.difficulty)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor((inProgressQuestId != -1 && quest.sidequest_id != inProgressQuestId) ? .gray : .black)
                    Text("RANK")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor((inProgressQuestId != -1 && quest.sidequest_id != inProgressQuestId) ? .gray.opacity(0.7) : .black.opacity(0.7))
                }
                .frame(width: 60)
                .frame(maxHeight: .infinity)
                .background((inProgressQuestId != -1 && quest.sidequest_id != inProgressQuestId) ? Color(.systemGray5) : colorForDifficulty(quest.difficulty))
                .cornerRadius(14, corners: [.topLeft, .bottomLeft])
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(quest.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor((inProgressQuestId != -1 && quest.sidequest_id != inProgressQuestId) ? .gray : .black)
                    Text(quest.short_description)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor((inProgressQuestId != -1 && quest.sidequest_id != inProgressQuestId) ? .gray.opacity(0.8) : .black.opacity(0.8))
                    HStack {
                        Text(quest.estimated_duration)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor((inProgressQuestId != -1 && quest.sidequest_id != inProgressQuestId) ? .gray : .gray)
                        Spacer()
                        Text("\(quest.xp_reward_amount) XP")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor((inProgressQuestId != -1 && quest.sidequest_id != inProgressQuestId) ? .gray : Color.purple)
                    }
                }
                .padding(.vertical, 18)
                .padding(.horizontal, 16)
            }
            .frame(height: 90)
            .background((inProgressQuestId != -1 && quest.sidequest_id != inProgressQuestId) ? Color(.systemGray6) : Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke((inProgressQuestId != -1 && quest.sidequest_id != inProgressQuestId) ? Color.gray.opacity(0.3) : Color.purple.opacity(0.18), lineWidth: 2)
            )
            .shadow(color: isPressed ? Color.purple.opacity(0.18) : Color.purple.opacity(0.07), radius: isPressed ? 16 : 6, x: 0, y: 2)
            .scaleEffect(isPressed ? 1.03 : 1.0)
            .padding(.horizontal, 12)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .opacity((inProgressQuestId != -1 && quest.sidequest_id != inProgressQuestId) ? 0.6 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    QuestRowView(
        quest: Quest(
            sidequest_id: 1,
            name: "Morning Meditation",
            difficulty: "C",
            short_description: "Start your day with clarity and purpose",
            long_description: "Begin your day with 10 minutes of meditation...",
            estimated_duration: "10 mins",
            xp_reward_amount: 50,
            gold_reward_amount: 10,
            badger_img_url: nil,
            banner_img_url: nil
        ),
        inProgressQuestId: -1,
        isPressed: false,
        onTap: {}
    )
} 