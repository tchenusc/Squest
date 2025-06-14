import Foundation
import Supabase
import Combine
import SwiftUI
import CoreData

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

    // Computed properties to match the original FriendsViewModel's functionality
    var displayedFriends: [Friend] {
        switch selectedFilter {
        case .myFriends:
            return friends
        case .requests:
            return requests
        }
    }

    var displayedFriendsCount: Int {
        switch selectedFilter {
        case .myFriends:
            return friendsCount
        case .requests:
            return requestsCount
        }
    }

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

    // New methods to handle friend request actions
    func confirmRequest(_ friend: Friend, currentUserId: UUID) async {
        let friendId = friend.id
        withAnimation(.easeInOut(duration: 0.3)) {
            self.animatingRequestId = friendId
        }

        // Delay the actual removal to allow animation to complete
        // Then perform Supabase update and refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            Task { @MainActor in
                do {
                    // Update the status in friends_table to 'accepted'
                    _ = try await self.client.from("friends_table")
                        .update(["status": "accepted"])
                        .eq("user_id1", value: friendId.uuidString)
                        .eq("user_id2", value: currentUserId.uuidString)
                        .execute()

                    // Refresh friend list from server
                    await self.loadFriends(for: currentUserId)
                    print("✅ Confirmed friend request for \(friend.name).")

                } catch {
                    print("❌ Failed to confirm request: \(error)")
                }
                self.animatingRequestId = nil
            }
        }
    }

    func denyRequest(_ friend: Friend, currentUserId: UUID) async {
        let friendId = friend.id
        withAnimation(.easeInOut(duration: 0.3)) {
            self.animatingRequestId = friendId
        }

        // Delay the actual removal to allow animation to complete
        // Then perform Supabase deletion and refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            Task { @MainActor in
                do {
                    // Delete the request from friends_table
                    _ = try await self.client.from("friends_table")
                        .delete()
                        .eq("user_id1", value: friendId.uuidString)
                        .eq("user_id2", value: currentUserId.uuidString)
                        .execute()

                    // Refresh friend list from server
                    await self.loadFriends(for: currentUserId)
                    print("✅ Denied friend request for \(friend.name).")

                } catch {
                    print("❌ Failed to deny request: \(error)")
                }
                self.animatingRequestId = nil
            }
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

    // MARK: - Core Data Update Function
    /// Updates the Core Data FriendList entity with the current friends and requests.
    /// This function first clears all existing FriendList entries and then recreates them.
    /// - Parameter context: The NSManagedObjectContext to perform Core Data operations on.
    func updateCoreDataFriendList(context: NSManagedObjectContext) async {
        // Delete existing FriendList objects to avoid duplicates and reflect current state
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FriendList.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            print("✅ Cleared existing FriendList Core Data entries.")
        } catch {
            print("❌ Failed to clear existing FriendList Core Data entries: \(error.localizedDescription)")
            // Continue to attempt adding new data even if clearing fails
        }

        // Add current friends
        for friend in self.friends {
            let newFriend = FriendList(context: context)
            newFriend.name = friend.name
            newFriend.username = friend.username
            newFriend.lastActive = friend.lastActive
            newFriend.onQuest = friend.onQuest
            newFriend.profileInitials = friend.profileInitials
            newFriend.level = Int64(friend.level)
            newFriend.listType = "friend" // New attribute for list type
        }

        // Add current requests
        for request in self.requests {
            let newRequest = FriendList(context: context)
            newRequest.name = request.name
            newRequest.username = request.username
            newRequest.lastActive = request.lastActive
            newRequest.onQuest = request.onQuest
            newRequest.profileInitials = request.profileInitials
            newRequest.level = Int64(request.level)
            newRequest.listType = "request" // New attribute for list type
        }

        await MainActor.run {
            do {
                try context.save()
                print("✅ Successfully updated FriendList Core Data with current friends and requests.")
            } catch {
                print("❌ Failed to save FriendList Core Data: \(error.localizedDescription)")
            }
        }
    }

    /// Function to set the curr_user_id of the first FriendListMain object and manage friend data loading.
    /// - Parameters:
    ///   - context: The NSManagedObjectContext to perform Core Data operations on.
    ///   - userId: The current user's UUID.
    ///   - firstRun: A boolean indicating if this is the initial run, defaults to true.
    func setCurrentUserFriendList(context: NSManagedObjectContext, userId: UUID, firstRun: Bool = true) async {
        let request: NSFetchRequest<FriendListMain> = FriendListMain.fetchRequest()
        request.fetchLimit = 1

        do {
            let results = try context.fetch(request)

            if let friendListMain = results.first {
                friendListMain.curr_user_id = userId

                let initialDirtyBit = friendListMain.dirty_bit
                let isSame = await self.checkIfDirtyBitSame(oldDirtyBit: initialDirtyBit, for: userId)

                if !isSame {
                    await MainActor.run {
                        friendListMain.dirty_bit = dirtyBit
                    }
                    await self.loadFriends(for: userId)
                    // After loading friends, update Core Data
                    await self.updateCoreDataFriendList(context: context)
                } else {
                    // Only load from Core Data if it's the first run and dirty bit is same
                    if firstRun {
                        self.loadFriendsFromCoreData(context: context)
                    }
                    print("ℹ️ FriendListMain: Dirty bit is up-to-date. No data refresh needed.")
                }

                await MainActor.run {
                    do {
                        try context.save()
                    } catch {
                        print("❌ Failed to save FriendListMain after update: \(error)")
                    }
                }
            } else {
                print("ℹ️ No FriendListMain object found to set curr_user_id. Please ensure it's seeded.")
            }
        } catch {
            print("❌ Error fetching FriendListMain to set curr_user_id: \(error)")
        }
    }

    func sendFriendRequest(to username: String, from currentUserId: UUID) async throws {
        do {
            // First, get the user ID for the given username
            let response = try await client
                .from("users")
                .select("id")
                .eq("username", value: username)
                .limit(1)
                .execute()
            
            let userData = try JSONDecoder().decode([UserData].self, from: response.data)
            
            guard let targetUserId = userData.first?.id else {
                throw NSError(domain: "FriendsListViewModel", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
            }
            
            // Check if a friendship already exists
            let existingResponse = try await client
                .from("friends_table")
                .select()
                .or("user_id1.eq.\(currentUserId.uuidString),user_id2.eq.\(currentUserId.uuidString)")
                .or("user_id1.eq.\(targetUserId.uuidString),user_id2.eq.\(targetUserId.uuidString)")
                .execute()
            
            let existingFriendships = try JSONDecoder().decode([FriendshipData].self, from: existingResponse.data)
            
            if !existingFriendships.isEmpty {
                throw NSError(domain: "FriendsListViewModel", code: 400, userInfo: [NSLocalizedDescriptionKey: "Friendship already exists"])
            }
            
            // Create the friend request
            _ = try await client
                .from("friends_table")
                .insert([
                    "user_id1": currentUserId.uuidString,
                    "user_id2": targetUserId.uuidString,
                    "status": "pending"
                ])
                .execute()
            
            print("✅ Sent friend request to \(username)")
            
        } catch {
            print("❌ Failed to send friend request: \(error)")
            throw error
        }
    }
    
    // Helper structs for decoding
    private struct UserData: Decodable {
        let id: UUID
    }
    
    private struct FriendshipData: Decodable {
        let user_id1: UUID
        let user_id2: UUID
        let status: String
    }
}

extension FriendsListViewModel {
    /// Loads friends and requests from Core Data and populates the ViewModel's arrays.
    /// - Parameter context: The NSManagedObjectContext to perform Core Data operations on.
    func loadFriendsFromCoreData(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<FriendList> = FriendList.fetchRequest()

        do {
            let coreDataFriends = try context.fetch(fetchRequest)

            var fetchedFriends: [Friend] = []
            var fetchedRequests: [Friend] = []

            for coreDataFriend in coreDataFriends {
                let friend = Friend(
                    name: coreDataFriend.name ?? "Unknown",
                    username: coreDataFriend.username ?? "@unknown",
                    lastActive: coreDataFriend.lastActive ?? "",
                    onQuest: coreDataFriend.onQuest,
                    profileInitials: coreDataFriend.profileInitials ?? "?",
                    level: Int(coreDataFriend.level)
                )

                if coreDataFriend.listType == "friend" {
                    fetchedFriends.append(friend)
                } else if coreDataFriend.listType == "request" {
                    fetchedRequests.append(friend)
                }
            }
            
            self.friends = fetchedFriends
            self.requests = fetchedRequests
            self.friendsCount = fetchedFriends.count
            self.requestsCount = fetchedRequests.count

            print("✅ Successfully loaded friends and requests from Core Data.")
        } catch {
            print("❌ Failed to load friends from Core Data: \(error.localizedDescription)")
        }
    }
}
