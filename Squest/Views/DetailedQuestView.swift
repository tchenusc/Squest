import SwiftUI
import CoreData

struct DetailedQuestView: View {
    let quest: Quest
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userProfile: UserProfile
    
    @State private var globalInProgressQuestId: Int64 = -1 // State to hold global in-progress ID
    
    var isInProgress: Bool { checkCurrentQuestInProgressStatus() }
    var onClose: (() -> Void)? = nil
    
    /// Closure to call when the quest is successfully completed
    var onComplete: ((_ questName: String, _ xp: Int, _ gold: Int) -> Void)? = nil
    
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
            if isInProgress { // If *this* quest is in progress
                HStack(spacing: 16) {
                    Button(action: {
                        // Cancel Quest action: reset quest ID in Core Data
                        cancelQuest()
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
                        // Complete Quest action: reset quest ID in Core Data
                        // Call the completion handler before closing
                        onComplete?(quest.name, quest.xp_reward_amount, quest.gold_reward_amount)
                        cancelQuest()
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
            } else if globalInProgressQuestId == -1 { // If no quest is in progress globally
                Button(action: {
                    // Start Quest action: save quest ID to Core Data
                    startQuest()
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
                Text("Another quest is in progress.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .multilineTextAlignment(.center)
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
        .onAppear {
            checkGlobalInProgressQuest()
        }
    }
    
    // Check if *this* quest is the one in progress
    private func checkCurrentQuestInProgressStatus() -> Bool {
        let request: NSFetchRequest<BackgroundData> = BackgroundData.fetchRequest()
        // Safely unwrap userId and use %@ for UUID predicate
        guard let userId = userProfile.current_user_id else {
            return false // No user logged in
        }
        request.predicate = NSPredicate(format: "user_id == %@", userId as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(request)
            if let data = results.first, data.quest_id_IP == quest.sidequest_id {
                return true
            } else {
                return false
            }
        } catch {
            print("Error fetching current quest in-progress status: \(error)")
            return false
        }
    }
    
    // Fetch the globally in-progress quest ID
    private func checkGlobalInProgressQuest() {
        let request: NSFetchRequest<BackgroundData> = BackgroundData.fetchRequest()
        // Safely unwrap userId and use %@ for UUID predicate
        guard let userId = userProfile.current_user_id else {
            globalInProgressQuestId = -1
            return // No user logged in
        }
        request.predicate = NSPredicate(format: "user_id == %@", userId as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(request)
            if let data = results.first {
                globalInProgressQuestId = data.quest_id_IP
            } else {
                globalInProgressQuestId = -1
            }
        } catch {
            print("Error fetching global in-progress quest: \(error)")
            globalInProgressQuestId = -1
        }
    }
    
    private func startQuest() {
        // Safely unwrap userId
        guard let userId = userProfile.current_user_id else {
             print("Error starting quest: No user logged in")
             return
        }
        
        let request: NSFetchRequest<BackgroundData> = BackgroundData.fetchRequest()
        // Use %@ for UUID predicate
        request.predicate = NSPredicate(format: "user_id == %@", userId as CVarArg)
        
        do {
            let results = try viewContext.fetch(request)
            let backgroundData: BackgroundData
            
            if let existingData = results.first {
                backgroundData = existingData
            } else {
                backgroundData = BackgroundData(context: viewContext)
                backgroundData.user_id = userId
            }
            
            backgroundData.quest_id_IP = Int64(quest.sidequest_id)
            backgroundData.time_started = Date()
            
            try viewContext.save()
        } catch {
            print("Error starting quest: \(error)")
        }
    }
    
    private func cancelQuest() {
        // Safely unwrap userId
         guard let userId = userProfile.current_user_id else {
             print("Error cancelling quest: No user logged in")
             return
         }
        
        let request: NSFetchRequest<BackgroundData> = BackgroundData.fetchRequest()
        // Use %@ for UUID predicate
        request.predicate = NSPredicate(format: "user_id == %@", userId as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(request)
            if let existingData = results.first {
                existingData.quest_id_IP = -1
                existingData.time_started = nil
                try viewContext.save()
            }
        } catch {
            print("Error cancelling quest: \(error)")
        }
    }
}

// Helper to get color for difficulty (assuming this is defined elsewhere and accessible)
// func colorForDifficulty(_ difficulty: String) -> Color { ... }

struct DetailedQuestView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleQuest = Quest(
            sidequest_id: 1,
            name: "Sample Quest",
            difficulty: "A",
            short_description: "This is a short description.",
            long_description: "This is a long description that provides more details about the quest.",
            estimated_duration: "30 minutes",
            xp_reward_amount: 100,
            gold_reward_amount: 50,
            badger_img_url: nil,
            banner_img_url: nil
        )
        
        return DetailedQuestView(quest: sampleQuest)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(UserProfile(userId: UUID(), email: "preview@test.com")) // Provide a UserProfile with a UUID for preview
    }
} 
