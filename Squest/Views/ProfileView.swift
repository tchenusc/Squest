import SwiftUI

struct ProfileView: View {
    @ObservedObject var userProfile: UserProfile
    @State private var showingCoinDescription: Bool = false
    @State private var coinHStackFrame: CGRect = .zero
    @State private var isCoinDisplayPressed: Bool = false
    @State private var shouldCoinDisplayAnimateOnDismiss: Bool = false
    @StateObject private var imageLoader = ImageLoader()
    @StateObject private var viewModel: ProfileViewModel
    
    init(userProfile: UserProfile) {
        self.userProfile = userProfile
        _viewModel = StateObject(wrappedValue: ProfileViewModel(userProfile: userProfile))
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                ZStack(alignment: .topTrailing) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Coin Display in top left
                        HStack {
                            HStack {
                                Image("CoinPouch")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                Text("\(viewModel.coins)")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .background(GeometryReader { geometry in
                                Color.clear.onAppear {
                                    coinHStackFrame = geometry.frame(in: .global)
                                }
                            })
                            .scaleEffect(isCoinDisplayPressed || shouldCoinDisplayAnimateOnDismiss ? 0.95 : 1.0)
                            .animation(.easeOut(duration: 0.2), value: isCoinDisplayPressed)
                            .animation(.easeOut(duration: 0.2), value: shouldCoinDisplayAnimateOnDismiss)
                            .onTapGesture {
                                withAnimation {
                                    showingCoinDescription.toggle()
                                }
                                isCoinDisplayPressed = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    isCoinDisplayPressed = false
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        // Profile Header
                        VStack(spacing: 16) {
                            ZStack {
                                if let image = imageLoader.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(.blue)
                                }
                            }
                            .onAppear {
                                imageLoader.preload(from: URL(string: userProfile.avatarUrl ?? ""))
                            }
                            .onChange(of: userProfile.avatarUrl) { _, newUrl in
                                imageLoader.preload(from: URL(string: newUrl ?? ""))
                            }
                            VStack(spacing: 4) {
                                Text(userProfile.displayedName ?? "User")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.black)
                                Text("@\(userProfile.username ?? "user")")
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 50)
                        .padding(.bottom, 24)
                        .background(Color(.systemGray6).opacity(0.5))
                        VStack(alignment: .leading, spacing: 24) {
                            // Level Progress Section
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Level Progress")
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundColor(.black)
                                    Spacer()
                                    Text(viewModel.levelLabel)
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(red: 0.49, green: 0.4, blue: 0.82))
                                        .cornerRadius(12)
                                }
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(.systemGray5))
                                            .frame(height: 12)
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(red: 0.49, green: 0.4, blue: 0.82))
                                            .frame(width: geometry.size.width * viewModel.levelProgress, height: 12)
                                    }
                                }
                                .frame(height: 12)
                                Text(viewModel.levelProgressText)
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            // Stats Grid
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Statistics")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.black)
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 20) {
                                    ForEach(viewModel.stats, id: \.title) { stat in
                                        StatView(value: stat.value, title: stat.title)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            // Recent Activity Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recent Activity")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.black)
                                ForEach(viewModel.recentActivity) { activity in
                                    ActivityRow(
                                        icon: activity.icon,
                                        title: activity.title,
                                        time: activity.time
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 24)
                    }
                    // Top right buttons (Edit and Settings)
                    HStack(spacing: 8) {
                        NavigationLink(destination: EditProfileView(userProfile: userProfile)) {
                            Image(systemName: "pencil")
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                        }
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.trailing, 20)
                }
            }
            .background(Color(.systemGray6).opacity(0.5).ignoresSafeArea())
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

