import SwiftUI
import CoreData

/// ViewModel responsible for managing the home screen's quest list and state
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var inProgressQuestId: Int64 = -1
    @Published private(set) var quests: [Quest] = []
    @Published var selectedQuestID: UUID? = nil
    @Published var showDetail: Bool = false
    @Published private(set) var pressedQuestID: UUID? = nil

    // MARK: - Private Properties
    private let viewContext: NSManagedObjectContext
    
    // MARK: - Initialization
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        loadMockQuests()
        checkInProgressQuest()
    }
    
    // MARK: - Public Methods
    func setPressedQuestID(_ id: UUID?) {
        pressedQuestID = id
    }
    
    func selectQuest(_ id: UUID) {
        selectedQuestID = id
        showDetail = true
    }
    
    func dismissDetail() {
        showDetail = false
        checkInProgressQuest()
    }

    // MARK: - Computed Properties
    var sortedQuests: [Quest] {
        quests.sorted { quest1, quest2 in
            if quest1.sidequest_id == inProgressQuestId {
                return true
            }
            if quest2.sidequest_id == inProgressQuestId {
                return false
            }
            let difficultyValue1 = difficultySortValue(quest1.difficulty)
            let difficultyValue2 = difficultySortValue(quest2.difficulty)
            return difficultyValue1 != difficultyValue2 ? difficultyValue1 < difficultyValue2 : quest1.xp_reward_amount > quest2.xp_reward_amount
        }
    }

    // MARK: - Private Methods
    private func loadMockQuests() {
        quests = [
            Quest(sidequest_id: 1, name: "Morning Meditation", difficulty: "C", short_description: "Start your day with clarity and purpose", long_description: "Begin your day with 10 minutes of meditation...", estimated_duration: "10 mins", xp_reward_amount: 50, gold_reward_amount: 10, badger_img_url: nil, banner_img_url: nil),
            Quest(sidequest_id: 2, name: "Nature Explorer", difficulty: "B", short_description: "Take a walk in nature and document 3 interesting findings", long_description: "Step outside and immerse yourself in nature...", estimated_duration: "30 mins", xp_reward_amount: 100, gold_reward_amount: 20, badger_img_url: nil, banner_img_url: nil),
            Quest(sidequest_id: 3, name: "Knowledge Expansion", difficulty: "B", short_description: "Learn something new and share with a friend", long_description: "Dedicate 45 minutes to learning about a new topic...", estimated_duration: "45 mins", xp_reward_amount: 120, gold_reward_amount: 25, badger_img_url: nil, banner_img_url: nil),
            Quest(sidequest_id: 4, name: "Digital Detox", difficulty: "A", short_description: "Go 3 hours without checking your phone or social media", long_description: "Unplug and disconnect for three consecutive hours...", estimated_duration: "3 hours", xp_reward_amount: 200, gold_reward_amount: 40, badger_img_url: nil, banner_img_url: nil),
            Quest(sidequest_id: 5, name: "Ultimate Challenge", difficulty: "S", short_description: "Complete all quests in one day", long_description: "Attempt to complete every available quest within a single 24-hour period...", estimated_duration: "5 hours", xp_reward_amount: 500, gold_reward_amount: 100, badger_img_url: nil, banner_img_url: nil),
            Quest(sidequest_id: 6, name: "Legendary Feat", difficulty: "S++", short_description: "Achieve the impossible!", long_description: "Complete a hidden legendary quest...", estimated_duration: "8 hours", xp_reward_amount: 1000, gold_reward_amount: 250, badger_img_url: nil, banner_img_url: nil),
            Quest(sidequest_id: 7, name: "Failed Quest", difficulty: "F", short_description: "Try again next time.", long_description: "This quest represents a challenge that was attempted but not completed...", estimated_duration: "--", xp_reward_amount: 0, gold_reward_amount: 0, badger_img_url: nil, banner_img_url: nil)
        ]
    }

    func checkInProgressQuest() {
        let request: NSFetchRequest<BackgroundData> = BackgroundData.fetchRequest()
        request.fetchLimit = 1
        do {
            let results = try viewContext.fetch(request)
            inProgressQuestId = results.first?.quest_id_IP ?? -1
        } catch {
            print("Error fetching in-progress quest: \(error)")
            inProgressQuestId = -1
        }
    }
} 