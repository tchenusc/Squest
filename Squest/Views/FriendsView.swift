import SwiftUI

struct Friend: Identifiable {
    let id = UUID()
    let name: String
    let username: String
    let lastActive: String // e.g., "1h ago", "Just now", "2d ago"
    let onQuest: String?
    let profileInitials: String // e.g., "JR"
    let level: Int
}

class FriendsViewModel: ObservableObject {
    @Published var friends: [Friend] = [
        Friend(name: "Jamie Rodriguez", username: "@jamier", lastActive: "1h ago", onQuest: "Morning Walk", profileInitials: "JR", level: 24),
        Friend(name: "Taylor Patel", username: "@taylorp", lastActive: "2d ago", onQuest: nil, profileInitials: "TP", level: 19),
        Friend(name: "Casey Williams", username: "@caseyw", lastActive: "Just now", onQuest: "Digital Detox", profileInitials: "CW", level: 21),
        Friend(name: "Riley Garcia", username: "@rileyg", lastActive: "5h ago", onQuest: nil, profileInitials: "RG", level: 17)
    ]

    @Published var requests: [Friend] = [
        Friend(name: "Request User 1", username: "@req1", lastActive: "1d ago", onQuest: nil, profileInitials: "RU", level: 10),
        Friend(name: "Request User 2", username: "@req2", lastActive: "3h ago", onQuest: nil, profileInitials: "RU", level: 14)
    ]

    @Published var selectedFilter: FriendFilter = .myFriends
    @Published var requestsCount: Int = 2
    @Published var animatingRequestId: UUID? = nil

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
            return friends.count
        case .requests:
            return requests.count
        }
    }
    
    func confirmRequest(_ friend: Friend) {
        withAnimation(.easeInOut(duration: 0.3)) {
            animatingRequestId = friend.id
        }
        
        // Delay the actual removal to allow animation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let index = self.requests.firstIndex(where: { $0.id == friend.id }) {
                let confirmedFriend = self.requests.remove(at: index)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    self.friends.append(confirmedFriend)
                    self.requestsCount = self.requests.count
                    self.animatingRequestId = nil
                }
            }
        }
    }
    
    func denyRequest(_ friend: Friend) {
        withAnimation(.easeInOut(duration: 0.3)) {
            animatingRequestId = friend.id
        }
        
        // Delay the actual removal to allow animation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let index = self.requests.firstIndex(where: { $0.id == friend.id }) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    self.requests.remove(at: index)
                    self.requestsCount = self.requests.count
                    self.animatingRequestId = nil
                }
            }
        }
    }
}

enum FriendFilter: String, CaseIterable, Identifiable {
    case myFriends = "My Friends"
    case requests = "Requests"

    var id: String { self.rawValue }
}

struct FriendsView: View {
    @StateObject private var viewModel = FriendsViewModel()
    @State private var myFriendsButtonFrame: CGRect = .zero
    @State private var requestsButtonFrame: CGRect = .zero

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Friends")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                        .padding(.top, 50)

                    Text("Adventure is better with friends")
                        .font(.subheadline)
                        .foregroundColor(Color(white: 0.5))
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)

                HStack {
                    Spacer()
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 240/255, green: 240/255, blue: 245/255))

                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .frame(width: selectedIndicatorWidth, height: indicatorHeight)
                            .offset(x: selectedIndicatorXOffset, y: 0)

                        HStack(spacing: 0) {
                            FilterButton(title: "My Friends", isSelected: viewModel.selectedFilter == .myFriends) {
                                withAnimation(.spring()) {
                                    viewModel.selectedFilter = .myFriends
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onAppear { self.myFriendsButtonFrame = geometry.frame(in: .named("filter_control_space")) }
                                }
                            )

                            FilterButton(title: "Requests (\(viewModel.requestsCount))", isSelected: viewModel.selectedFilter == .requests) {
                                withAnimation(.spring()) {
                                    viewModel.selectedFilter = .requests
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onAppear { self.requestsButtonFrame = geometry.frame(in: .named("filter_control_space")) }
                                }
                            )
                        }
                        .padding(8)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .cornerRadius(20)
                    .coordinateSpace(name: "filter_control_space")
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 25)

                HStack(alignment: .center) {
                    Text(viewModel.selectedFilter == .myFriends ? "Your Friends (\(viewModel.displayedFriendsCount))" : "Friend Requests (\(viewModel.displayedFriendsCount))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.leading, 20)

                    Spacer()

                    Button(action: {
                        print("Add New Friend")
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 14))
                            Text("Add New")
                                .font(.system(size: 14, weight: .regular))
                        }
                        .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.9))
                    }
                    .padding(.trailing, 20)
                }
                .padding(.bottom, 15)

                ScrollView {
                    VStack(spacing: 12) {
                        if viewModel.selectedFilter == .requests && viewModel.requests.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(white: 0.7))
                                Text("No Friend Requests")
                                    .font(.headline)
                                    .foregroundColor(Color(white: 0.5))
                                Text("When someone sends you a friend request, it will appear here")
                                    .font(.subheadline)
                                    .foregroundColor(Color(white: 0.5))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            ForEach(viewModel.displayedFriends) { friend in
                                FriendRow(friend: friend, viewModel: viewModel)
                                    .opacity(viewModel.animatingRequestId == friend.id ? 0 : 1)
                                    .offset(x: viewModel.animatingRequestId == friend.id ? 50 : 0)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                Spacer()
            }
            .navigationBarHidden(true)
            .background(Color(red: 250/255, green: 250/255, blue: 252/255))
        }
    }

    var selectedIndicatorWidth: CGFloat {
        viewModel.selectedFilter == .myFriends ? myFriendsButtonFrame.width : requestsButtonFrame.width
    }

    var indicatorHeight: CGFloat {
        myFriendsButtonFrame.height
    }

    var selectedIndicatorXOffset: CGFloat {
        let selectedFrame = viewModel.selectedFilter == .myFriends ? myFriendsButtonFrame : requestsButtonFrame
        return selectedFrame.minX
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .black : Color(red: 0.4, green: 0.4, blue: 0.4))
                .padding(.vertical, 8)
                .padding(.horizontal, 0)
                .background(Color.clear)
                .cornerRadius(20)
        }
    }
}

struct FriendRow: View {
    let friend: Friend
    @ObservedObject var viewModel: FriendsViewModel
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.49, green: 0.4, blue: 0.82))
                    .frame(width: 50, height: 50)
                Text(friend.profileInitials)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(friend.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        if viewModel.selectedFilter == .requests {
                            Text(friend.username)
                                .font(.subheadline)
                                .foregroundColor(Color(white: 0.4))
                        }
                    }
                    
                    Spacer()
                    
                    if viewModel.selectedFilter == .myFriends {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 15))
                        Text("Lvl \(friend.level)")
                            .font(.subheadline)
                            .foregroundColor(Color(white: 0.4))
                    }
                }

                if viewModel.selectedFilter == .myFriends {
                    HStack(spacing: 4) {
                        Text("Active \(friend.lastActive)")
                            .font(.caption2)
                            .foregroundColor(Color(white: 0.4))
                        
                        if let quest = friend.onQuest {
                            Text("•")
                                .font(.caption2)
                                .foregroundColor(Color(white: 0.4))
                            Text("On quest: \(quest)")
                                .font(.caption2)
                                .foregroundColor(Color(red: 0.49, green: 0.4, blue: 0.82))
                        }
                    }
                }
            }
            
            if viewModel.selectedFilter == .requests {
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.confirmRequest(friend)
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 32))
                    }
                    
                    Button(action: {
                        viewModel.denyRequest(friend)
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 32))
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    FriendsView()
} 

