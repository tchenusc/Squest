import Foundation
import Supabase
import Combine

// MARK: - Decodable Structs for Supabase Response

struct FriendRecord: Decodable {
    let user_id1: UUID?
    let user_id2: UUID?
    let status: String
    let username: String
    let displayed_name: String
    let last_online: String
    let is_online: Bool
    let level: Int
}

// New Decodable struct for fetching only the dirty bit
struct UserDirtyBitData: Decodable {
    let friends_list_dirty_bit: UUID?
}

@MainActor
class FriendsListViewModel: ObservableObject {
    @Published var friends: [Friend] = []
    @Published var requests: [Friend] = []
    @Published var selectedFilter: FriendFilter = .myFriends
    @Published var friendsCount: Int = 0
    @Published var requestsCount: Int = 0
    @Published var animatingRequestId: UUID? = nil
    @Published var dirtyBit: UUID? = nil

    private var client = SupabaseManager.shared.client

    func loadFriends(for currentUserId: UUID) async {
        do {
            async let responseA = client.rpc("get_accepted_friends_as_user1", params: ["current_user_id": currentUserId.uuidString]).execute()
            async let responseB = client.rpc("get_accepted_friends_as_user2", params: ["current_user_id": currentUserId.uuidString]).execute()
            async let responsePendingA = client.rpc("get_pending_requests_as_user2", params: ["current_user_id": currentUserId.uuidString]).execute()
            async let responsePendingB = client.rpc("get_pending_requests_as_user1", params: ["current_user_id": currentUserId.uuidString]).execute()

            let (resA, resB, resPendingA, resPendingB) = try await (responseA, responseB, responsePendingA, responsePendingB)

            let acceptedResultA = try JSONDecoder().decode([FriendRecord].self, from: resA.data)
            let acceptedResultB = try JSONDecoder().decode([FriendRecord].self, from: resB.data)
            let pendingResultA = try JSONDecoder().decode([FriendRecord].self, from: resPendingA.data)
            let pendingResultB = try JSONDecoder().decode([FriendRecord].self, from: resPendingB.data)

            let fetchedAcceptedFriends = (acceptedResultA + acceptedResultB).map {
                createFriend(from: $0)
            }

            let fetchedPendingRequests = (pendingResultA + pendingResultB).map {
                createFriend(from: $0)
            }

            self.friends = fetchedAcceptedFriends
            self.requests = fetchedPendingRequests
            self.friendsCount = fetchedAcceptedFriends.count
            self.requestsCount = fetchedPendingRequests.count

            print("Fetched accepted friends: \(self.friends)")
            print("Fetched pending requests: \(self.requests)")

        } catch {
            print("Failed to load friends: \(error)")
        }
    }

    func clear() {
        friends = []
        requests = []
        selectedFilter = .myFriends
        friendsCount = 0
        requestsCount = 0
        animatingRequestId = nil
        dirtyBit = nil
    }
    
    func checkIfDirtyBitSame(oldDirtyBit: UUID?, for currentUserId: UUID) async -> Bool {
        do {
            let response = try await client
                .from("user_data")
                .select("friends_list_dirty_bit")
                .eq("user_id", value: currentUserId.uuidString)
                .limit(1)
                .execute()

            let userData = try JSONDecoder().decode([UserDirtyBitData].self, from: response.data)

            if let fetchedDirtyBit = userData.first?.friends_list_dirty_bit {
                dirtyBit = fetchedDirtyBit
                return oldDirtyBit == fetchedDirtyBit
            } else {
                print("No friends_list_dirty_bit found for user: \(currentUserId.uuidString)")
                return false // Or handle as appropriate if no dirty bit implies a change
            }
        } catch {
            print("❌ Failed to check dirty bit: \(error)")
            return false
        }
    }

    private func createFriend(from record: FriendRecord) -> Friend {
        let displayedName = record.displayed_name
        let username = record.username
        let lastOnlineTimestamp = record.last_online
        let isOnline = record.is_online
        let level = record.level
        let initials = generateInitials(from: displayedName, fallback: username)

        return Friend(
            name: displayedName,
            username: "@\(username)",
            lastActive: formatLastActive(lastOnlineTimestamp, isOnline: isOnline),
            onQuest: nil,
            profileInitials: initials,
            level: level
        )
    }

    private func formatLastActive(_ timestamp: String, isOnline: Bool) -> String {
        if isOnline {
            return "Just now"
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: timestamp) else {
            return "Unknown"
        }

        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.unitsStyle = .full
        return relativeFormatter.localizedString(for: date, relativeTo: Date())
    }

    private func generateInitials(from displayedName: String, fallback username: String) -> String {
        let nameComponents = displayedName.split(separator: " ").map { String($0) }
        if nameComponents.count >= 2 {
            return (nameComponents[0].prefix(1) + nameComponents[1].prefix(1)).uppercased()
        } else if let firstChar = displayedName.first {
            return String(firstChar).uppercased()
        } else if let firstChar = username.first {
            return String(firstChar).uppercased()
        } else {
            return "?"
        }
    }
}
