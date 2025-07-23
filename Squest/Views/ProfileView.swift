import SwiftUI

struct ProfileView: View {
    @ObservedObject var userProfile: UserProfile
    @State private var showingCoinDescription: Bool = false
    @State private var coinHStackFrame: CGRect = .zero
    @State private var isCoinDisplayPressed: Bool = false
    @State private var shouldCoinDisplayAnimateOnDismiss: Bool = false
    @StateObject private var imageLoader = ImageLoader()
    @StateObject private var viewModel: ProfileViewModel
    @State private var selectedBadge: BadgeWallView.Badge? = nil
    
    init(userProfile: UserProfile) {
        self.userProfile = userProfile
        _viewModel = StateObject(wrappedValue: ProfileViewModel(userProfile: userProfile))
    }
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .topTrailing) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Coin Display in top left
                        CoinDisplayView(
                            coins: viewModel.coins,
                            onTap: {
                                withAnimation {
                                    showingCoinDescription.toggle()
                                }
                            },
                            isPressed: $isCoinDisplayPressed,
                            shouldAnimateOnDismiss: $shouldCoinDisplayAnimateOnDismiss,
                            coinHStackFrame: $coinHStackFrame
                        )
                        // Profile Header
                        ProfileHeaderView(
                            displayedName: userProfile.displayedName,
                            username: userProfile.username,
                            avatarUrl: userProfile.avatarUrl,
                            imageLoader: imageLoader
                        )
                        VStack(alignment: .leading, spacing: 24) {
                            // Level Progress Section
                            LevelProgressView(
                                levelLabel: viewModel.levelLabel,
                                levelProgress: viewModel.levelProgress,
                                levelProgressText: viewModel.levelProgressText
                            )
                            // Stats Grid
                            StatsGridView(stats: viewModel.stats)
                            // Wall of Fame Section (Badges)
                            BadgeWallView(
                                badges: [
                                    .init(name: "Sunset Explorer", imageName: "badge_sunset", isCompleted: true),
                                    .init(name: "100-200", imageName: "badge_100to200", isCompleted: true),
                                    .init(name: "200-300", imageName: "badge_200to300", isCompleted: false),
                                    .init(name: "300-400", imageName: "badge_300to400", isCompleted: true),
                                    .init(name: "400-500", imageName: "badge_400to500", isCompleted: false)
                                ]
                            )
                        }
                        .padding(.bottom, 24)
                    }
                    // Top right buttons (Edit and Settings)
                    TopRightButtonsView(userProfile: userProfile)
                }
            }
            .background(Color.white.ignoresSafeArea())
            .onDisappear {
                showingCoinDescription = false
            }
            if showingCoinDescription {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showingCoinDescription = false
                        }
                        shouldCoinDisplayAnimateOnDismiss = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            shouldCoinDisplayAnimateOnDismiss = false
                        }
                    }
                    .zIndex(1)
                InfoBubbleView()
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity).animation(.interactiveSpring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)),
                            removal: .scale(scale: 0.8).combined(with: .opacity).animation(.interactiveSpring(response: 0.4, dampingFraction: 0.6, blendDuration: 0))
                        )
                    )
                    .position(x: coinHStackFrame.minX + 130, y: coinHStackFrame.maxY + 20)
                    .zIndex(2)
            }
        }
    }
}

#Preview {
    NavigationView {
        ProfileView(userProfile: UserProfile(displayedName: "John Doe", username: "johndoe", avatarUrl: "https://via.placeholder.com/150"))
    }
}

