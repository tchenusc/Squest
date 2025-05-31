import SwiftUI

struct DetailedQuestView: View {
    let quest: Quest
    var onClose: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 14) {
                    Text(quest.title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    
                    // Difficulty badge
                    Text("Difficulty: \(quest.rank)-Rank")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(colorForRank(quest.rank))
                        .cornerRadius(13)
                }
                Spacer()
                // Close button
                Button(action: { onClose?() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(8)
                }
            }
            .padding(.bottom, 18)
            
            // Description
            Text("Begin your day with 10 minutes of meditation to center yourself, clear your mind, and set intentions for the day ahead. Find a quiet space, sit comfortably, and focus on your breath.")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.black.opacity(0.85))
                .padding(.bottom, 24)
            
            // Estimated time
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .foregroundColor(Color.purple)
                Text("Estimated time: \(quest.duration)")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.black.opacity(0.8))
            }
            .padding(.bottom, 24)
            
            // Rewards section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "rosette")
                        .foregroundColor(.yellow)
                    Text("Rewards:")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                    Spacer()
                    Text("25 Points")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.black)
                }
                Text("\(quest.xp)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Color.purple)
                Text("Possible badge: ")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.black) +
                Text("Early Riser")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.black)
            }
            .padding(18)
            .background(Color.purple.opacity(0.07))
            .cornerRadius(14)
            .padding(.bottom, 36)
            
            Spacer()
            
            Button(action: { /* Start Quest action */ }) {
                Text("Start Quest")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.purple)
                    .cornerRadius(12)
            }
            .padding(.bottom, 18)
        }
        .padding(.top, 32)
        .padding(.horizontal, 24)
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.13), radius: 18, x: 0, y: 8)
        .padding(.horizontal, 16)
        .frame(maxWidth: 430)
    }
}

#Preview {
    DetailedQuestView(quest: quests[0])
} 