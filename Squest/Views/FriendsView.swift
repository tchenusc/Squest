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

    @Published var selectedFilter: FriendFilter = .myFriends // New: My Friends, Requests
    @Published var requestsCount: Int = 2 // Dummy count for requests

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

                HStack { // New HStack to center the segmented control
                    Spacer()
                    ZStack(alignment: .leading) { // ZStack to layer background and indicator
                        // The faint grey background for the whole segmented control
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 240/255, green: 240/255, blue: 245/255))

                        // The animated indicator (positioned behind the buttons)
                        RoundedRectangle(cornerRadius: 15) // Corner radius for the indicator itself
                            .fill(Color.white) // Change selected background to white
                            .frame(width: selectedIndicatorWidth, height: indicatorHeight)
                            .offset(x: selectedIndicatorXOffset, y: 0)

                        HStack(spacing: 0) {
                            FilterButton(title: "My Friends", isSelected: viewModel.selectedFilter == .myFriends) {
                                withAnimation(.spring()) { // Use spring animation
                                    viewModel.selectedFilter = .myFriends
                                }
                            }
                            .frame(maxWidth: .infinity) // Make button expand to fill available width
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onAppear { self.myFriendsButtonFrame = geometry.frame(in: .named("filter_control_space")) }
                                    .onChange(of: viewModel.selectedFilter) {
                                        self.myFriendsButtonFrame = geometry.frame(in: .named("filter_control_space"))
                                    }
                                }
                            )

                            FilterButton(title: "Requests (\(viewModel.requestsCount))", isSelected: viewModel.selectedFilter == .requests) {
                                withAnimation(.spring()) { // Use spring animation
                                    viewModel.selectedFilter = .requests
                                }
                            }
                            .frame(maxWidth: .infinity) // Make button expand to fill available width
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onAppear { self.requestsButtonFrame = geometry.frame(in: .named("filter_control_space")) }
                                    .onChange(of: viewModel.selectedFilter) {
                                        self.requestsButtonFrame = geometry.frame(in: .named("filter_control_space"))
                                    }
                                }
                            )
                        }
                        .padding(8) // Padding for the buttons relative to the ZStack's background
                    }
                    .frame(maxWidth: .infinity) // Make the ZStack fill available width
                    .frame(height: 45) // Fixed height for the entire segmented control (8 + 40 + 8)
                    .cornerRadius(20)
                    .coordinateSpace(name: "filter_control_space") // Name the coordinate space here
                    Spacer()
                }
                .padding(.horizontal, 20) // Apply horizontal padding to the new HStack
                .padding(.bottom, 25)

                HStack(alignment: .center) {
                    Text("Your Friends (\(viewModel.displayedFriendsCount))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.leading, 20)

                    Spacer()

                    Button(action: {
                        // Add New action
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
                        ForEach(viewModel.displayedFriends) { friend in
                            FriendRow(friend: friend)
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

    // Computed properties for indicator animation
    var selectedIndicatorWidth: CGFloat {
        viewModel.selectedFilter == .myFriends ? myFriendsButtonFrame.width : requestsButtonFrame.width
    }

    var indicatorHeight: CGFloat {
        // Assuming both buttons have the same height
        myFriendsButtonFrame.height
    }

    var selectedIndicatorXOffset: CGFloat {
        // The minX of the selected button relative to its parent HStack
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
                .background(Color.clear) // Make background clear, as it will be animated separately
                .cornerRadius(20) // Keep the corner radius for text alignment
                .shadow(color: .clear, radius: 0, x: 0, y: 0)
        }
    }
}

struct FriendRow: View {
    let friend: Friend

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
                    Text(friend.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 15))
                    Text("Lvl \(friend.level)")
                        .font(.subheadline)
                        .foregroundColor(Color(white: 0.4))
                }

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
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    FriendsView()
} 

