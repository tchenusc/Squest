import SwiftUI
import UIKit

enum FriendFilter: String, CaseIterable, Identifiable {
    case myFriends = "My Friends"
    case requests = "Requests"

    var id: String { self.rawValue }
}

struct AddFriendView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: FriendsListViewModel
    @EnvironmentObject var userProfile: UserProfile
    @State private var username: String = ""
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil
    @State private var isLoading = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var searchResults: [FriendsListViewModel.SearchedUser] = []
    @State private var isSearching = false
    
    let accentPurple = Color(red: 102/255, green: 51/255, blue: 153/255) // A deep purple
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white // Changed to white background
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header Section
                    VStack(spacing: 5) {
                        if !isTextFieldFocused {
                            Image("addFriendImg") // Using the new image asset
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200) // Adjust frame as needed
                                .padding(.bottom, 10)
                                .transition(.opacity)
                        }
                        Text("Add New Friend")
                            .font(.albertSans(s: 24))
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        
                        Text("Enter username to send a request")
                            .font(.albertSans(s: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    .padding(.top, 30)
                    .animation(.easeInOut(duration: 0.3), value: isTextFieldFocused)
                    
                    // Username Input Field
                    HStack(spacing: 0) {
                        Text("@")
                            .font(.albertSans(s: 16))
                            .foregroundColor(.gray)
                            .padding(.leading, 12)
                        
                        TextField("Username", text: $username)
                            .padding(12)
                            .padding(.leading, 0) // Remove default leading padding for TextField
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .font(.albertSans(s: 16))
                            .onChange(of: username) { oldValue, newValue in
                                if newValue.hasPrefix("@") {
                                    username = String(newValue.dropFirst())
                                }
                                isSearching = !username.isEmpty
                                errorMessage = nil
                                successMessage = nil
                                Task {
                                    if !username.isEmpty {
                                        searchResults = await viewModel.searchUsers(by: username)
                                    } else {
                                        searchResults = []
                                    }
                                }
                            }
                            .focused($isTextFieldFocused)
                    }
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isTextFieldFocused ? Color(red: 0.1, green: 0.5, blue: 0.7) : Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                    // User search results
                    if isSearching && !searchResults.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(searchResults) { user in
                                Button(action: {
                                    username = user.username
                                    isSearching = false
                                    searchResults = []
                                    isTextFieldFocused = false
                                }) {
                                    HStack {
                                        Text(user.displayed_name ?? user.username)
                                            .font(.albertSans(s: 16))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text("@\(user.username)")
                                            .font(.albertSans(s: 14))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                }
                                .background(Color.gray.opacity(0.08))
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.top, 2)
                    }
                    
                    // Error Message Display (local)
                    if let errorMessage = errorMessage {
                        HStack(spacing: 5) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.albertSans(s: 12))
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.albertSans(s: 12))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity)
                    }
                    // Success Message Display (local)
                    if let successMessage = successMessage {
                        HStack(spacing: 5) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.albertSans(s: 12))
                            Text(successMessage)
                                .foregroundColor(.green)
                                .font(.albertSans(s: 12))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity)
                    }
                    // Self-friend error
                    if !username.isEmpty, let myUsername = userProfile.username, username.lowercased() == myUsername.lowercased() {
                        HStack(spacing: 5) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.albertSans(s: 12))
                            Text("You cannot friend yourself.")
                                .foregroundColor(.red)
                                .font(.albertSans(s: 12))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity)
                    }
                    
                    // Send Request Button
                    Button(action: {
                        isTextFieldFocused = false // Dismiss keyboard
                        Task {
                            await sendRequest()
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 5)
                            }
                            Text("Send Request")
                                .fontWeight(.medium)
                                .font(.albertSans(s: 18))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(username.isEmpty || isLoading ? Color(red: 0.1, green: 0.5, blue: 0.7).opacity(0.6) : Color(red: 0.1, green: 0.5, blue: 0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(username.isEmpty || isLoading || (userProfile.username != nil && username.lowercased() == userProfile.username!.lowercased()))
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                    Spacer()
                }
                .padding(.horizontal, 25) // Overall horizontal padding
            }
            .navigationBarItems(trailing: Button("Cancel") {
                isTextFieldFocused = false // Dismiss keyboard
                dismiss()
            }
            .foregroundColor(accentPurple).font(.albertSans(s: 16)))
        }
    }
    
    private func sendRequest() async {
        guard !username.isEmpty else { return }
        
        if let myUsername = userProfile.username, username.lowercased() == myUsername.lowercased() {
            errorMessage = "You cannot friend yourself."
            successMessage = nil
            return
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            if let currentUserId = userProfile.current_user_id {
                try await viewModel.sendFriendRequest(to: username, from: currentUserId)
                successMessage = "Friend request sent to @\(username)!"
            }
        } catch let error as NSError {
            switch error.code {
            case 404:
                errorMessage = "User not found"
            case 400:
                errorMessage = error.localizedDescription
            default:
                errorMessage = error.localizedDescription
            }
        } catch {
            errorMessage = "An unexpected error occurred"
        }
        
        isLoading = false
    }
}

struct FriendsView: View {
    @EnvironmentObject var viewModel: FriendsListViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userProfile: UserProfile
    @State private var myFriendsButtonFrame: CGRect = .zero
    @State private var requestsButtonFrame: CGRect = .zero
    @State private var showingAddFriend = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Friends")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                        .padding(.top, 45)

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
                        showingAddFriend = true
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
                        } else if viewModel.selectedFilter == .myFriends && viewModel.friends.isEmpty {
                            VStack(spacing: 12) {
                                Image("noFriends")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 90, height: 90)
                                    .opacity(0.7)
                                Text("You have no friends yet!")
                                    .font(.headline)
                                    .foregroundColor(Color(white: 0.5))
                                Text("Add friends to start your adventure together.")
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
            .sheet(isPresented: $showingAddFriend) {
                AddFriendView()
            }
        }
        .onAppear {
            viewModel.selectedFilter = .myFriends
            if let userId = userProfile.current_user_id {
                Task { @MainActor in
                    await viewModel.setCurrentUserFriendList(context: viewContext, userId: userId, firstRun: false)
                }
            }
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
    @ObservedObject var viewModel: FriendsListViewModel
    @EnvironmentObject var userProfile: UserProfile
    
    var body: some View {
        HStack(spacing: 15) {
            if let urlString = friend.avatarUrl, !urlString.isEmpty {
                FriendAvatarImageView(urlString: urlString, size: 50)
            } else {
            ZStack {
                Circle()
                    .fill(Color(red: 0.49, green: 0.4, blue: 0.82))
                    .frame(width: 50, height: 50)
                Text(friend.profileInitials)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                }
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
                        Task { @MainActor in
                            if let currentUserId = userProfile.current_user_id {
                                await viewModel.confirmRequest(friend, currentUserId: currentUserId)
                            }
                        }
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 32))
                    }
                    
                    Button(action: {
                        Task { @MainActor in
                            if let currentUserId = userProfile.current_user_id {
                                await viewModel.denyRequest(friend, currentUserId: currentUserId)
                            }
                        }
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

struct FriendAvatarImageView: View {
    let urlString: String?
    var size: CGFloat = 50
    @StateObject private var loader = ImageLoader()
    var body: some View {
        ZStack {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color(red: 0.49, green: 0.4, blue: 0.82))
                    .frame(width: size, height: size)
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.6, height: size * 0.6)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .onAppear {
            loader.preload(from: URL(string: urlString ?? ""))
        }
        .onChange(of: urlString) { _, newUrl in
            loader.preload(from: URL(string: newUrl ?? ""))
        }
    }
}

#Preview {
    let previewUserProfile = UserProfile(userId: UUID(), email: "preview@example.com")
    let previewFriendsListViewModel = FriendsListViewModel()
    
    // Populate with some dummy data for preview
    previewFriendsListViewModel.friends = [
        Friend(name: "Jamie Rodriguez", username: "@jamier", lastActive: "1h ago", onQuest: "Morning Walk", profileInitials: "JR", level: 24),
        Friend(name: "Taylor Patel", username: "@taylorp", lastActive: "2d ago", onQuest: nil, profileInitials: "TP", level: 19)
    ]
    previewFriendsListViewModel.requests = [
        Friend(name: "Request User 1", username: "@req1", lastActive: "1d ago", onQuest: nil, profileInitials: "RU", level: 10)
    ]
    previewFriendsListViewModel.friendsCount = previewFriendsListViewModel.friends.count
    previewFriendsListViewModel.requestsCount = previewFriendsListViewModel.requests.count
    
    return FriendsView()
        .environmentObject(previewFriendsListViewModel)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(previewUserProfile)
} 

