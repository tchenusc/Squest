import SwiftUI

struct DetailedQuestView: View {
    let quest: Quest
    @Binding var inProgress: Bool // Accept inProgress as a Binding
    var onClose: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 14) {
                    Text(quest.name)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    
                    // Difficulty badge
                    Text("Difficulty: \(quest.difficulty) Rank")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(colorForDifficulty(quest.difficulty))
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
            .padding(.top, 24)
            
            // Description
            Text(quest.long_description)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.black.opacity(0.85))
                .padding(.bottom, 24)
            
            // Estimated time
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .foregroundColor(Color.purple)
                Text("Estimated time: \(quest.estimated_duration)")
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
                    Text("\(quest.gold_reward_amount) Gold")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.black)
                }
                Text("\(quest.xp_reward_amount) XP")
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
            
            // Conditional buttons based on quest state
            if !inProgress {
                Button(action: { 
                    // Start Quest action: set inProgress to true and close modal
                    inProgress = true
                    onClose?()
                }) {
                    Text("Start Quest")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.purple)
                        .cornerRadius(12)
                }
                .padding(.bottom, 18)
            } else {
                HStack(spacing: 16) {
                    Button(action: {
                        // Cancel Quest action: set inProgress to false and close modal
                        inProgress = false
                        onClose?()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // Complete Quest action: set inProgress to false and close modal
                        // Add logic to mark quest as completed separately if needed
                        inProgress = false
                        onClose?()
                    }) {
                        Text("Completed")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                }
                .padding(.bottom, 18)
            }
            
            
        }
        .padding(.top, 24)
        .padding(.horizontal, 24)
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.13), radius: 18, x: 0, y: 8)
        .padding(.horizontal, 16)
        .frame(maxWidth: 430)
    }
}

// Helper to get color for difficulty (assuming this is defined elsewhere and accessible)
// func colorForDifficulty(_ difficulty: String) -> Color { ... }

struct DetailedQuestView_Previews: PreviewProvider {
    static var previews: some View {
        // Define a sample quest for the preview
        let sampleQuest = Quest(
            sidequest_id: 1,
            name: "Sample Quest",
            difficulty: "C",
            short_description: "Short description for preview",
            long_description: "This is a sample long description for the preview of the detailed view.",
            estimated_duration: "15 mins",
            xp_reward_amount: 75,
            gold_reward_amount: 10,
            badger_img_url: nil,
            banner_img_url: nil,
            inProgress: false
        )
        
        DetailedQuestView(quest: sampleQuest, inProgress: .constant(false)) // Provide a constant binding for preview
    }
} 
