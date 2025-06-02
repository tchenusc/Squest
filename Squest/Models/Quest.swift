import Foundation
import CoreData

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
} 