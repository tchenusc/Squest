import SwiftUI

struct ProfileView: View {
    @ObservedObject var userProfile: UserProfile
    @State private var levelProgress: Double = 0.75 // Example progress value
    @State private var coins: Int = 1000 // Example coin amount
    @State private var showingCoinDescription: Bool = false // New state variable for pop-up
    @State private var coinHStackFrame: CGRect = .zero // New state variable to store the frame
    @State private var isCoinDisplayPressed: Bool = false // New state variable for tap animation
    @State private var shouldCoinDisplayAnimateOnDismiss: Bool = false // New state for dismissal animation
    @StateObject private var imageLoader = ImageLoader()
    
    var body: some View {
        ZStack {
            ScrollView {
                // Use ZStack to layer content and the settings button
                ZStack(alignment: .topTrailing) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Coin Display in top left
                        HStack { // Outer HStack for horizontal padding
                            HStack { // Inner HStack for coin display content
                                Image("CoinPouch")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                Text("\(coins)")
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
                            .background(GeometryReader { geometry in // Capture the frame of the inner HStack
                                Color.clear.onAppear {
                                    coinHStackFrame = geometry.frame(in: .global)
                                }
                            })
                            .scaleEffect(isCoinDisplayPressed || shouldCoinDisplayAnimateOnDismiss ? 0.95 : 1.0) // Apply consistent scale effect
                            .animation(.easeOut(duration: 0.2), value: isCoinDisplayPressed) // Animation for press effect
                            .animation(.easeOut(duration: 0.2), value: shouldCoinDisplayAnimateOnDismiss) // Animation for dismissal
                            .onTapGesture {
                                withAnimation { // Existing animation for appearance/disappearance of bubble
                                    showingCoinDescription.toggle()
                                }
                                // Add tap animation for coin display
                                isCoinDisplayPressed = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    isCoinDisplayPressed = false
                                }
                            }
                            Spacer() // Push the coin display to the left
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        // Profile Header
                        VStack(spacing: 16) {
                            // Avatar with shadow and border
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
                            
                            // Name and Username
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
                                    Text("Level 5")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(red: 0.49, green: 0.4, blue: 0.82))
                                        .cornerRadius(12)
                                }
                                
                                // Progress Bar
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(.systemGray5))
                                            .frame(height: 12)
                                        
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(red: 0.49, green: 0.4, blue: 0.82))
                                            .frame(width: geometry.size.width * levelProgress, height: 12)
                                    }
                                }
                                .frame(height: 12)
                                
                                Text("75% to next level")
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
                                    StatView(value: "1,234", title: "Points")
                                    StatView(value: "42", title: "Friends")
                                    StatView(value: "15", title: "Quests")
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Recent Activity Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recent Activity")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.black)
                                
                                ForEach(1...3, id: \.self) { index in
                                    ActivityRow(
                                        icon: "star.fill",
                                        title: "Completed Quest #\(index)",
                                        time: "\(index) hours ago"
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 24)
                    }
                    
                    // Top right buttons (Edit and Settings)
                    HStack(spacing: 8) {
                        // Edit Button
                        NavigationLink(destination: EditProfileView(userProfile: userProfile)) {
                            Image(systemName: "pencil")
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                        }
                        
                        // Settings Button
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

            // Popover as a top-level overlay on the main ZStack
            if showingCoinDescription {
                // Transparent background to dismiss the popover on outside tap
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.2)) { // Ensure animation on dismissal
                            showingCoinDescription = false
                        }
                        // Trigger coin display animation on dismissal
                        shouldCoinDisplayAnimateOnDismiss = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            shouldCoinDisplayAnimateOnDismiss = false
                        }
                    }
                    .zIndex(1) // Ensure it's above other content but below the popover itself
                
                InfoBubbleView()
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity).animation(.interactiveSpring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)),
                            removal: .scale(scale: 0.8).combined(with: .opacity).animation(.interactiveSpring(response: 0.4, dampingFraction: 0.6, blendDuration: 0))
                        )
                    ) // Pop in place effect with spring animation
                    .position(x: coinHStackFrame.minX + 130, y: coinHStackFrame.maxY + 20) // Position over coin pouch center
                    .zIndex(2) // Ensure the popover is above the transparent background
            }
        }
        // Keep navigationTitle if you want the default title appearance
        // .navigationTitle("Profile")
    }
}

struct InfoBubbleView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your earned coins.")
                .font(.firaSansBold(s: 14))
            +
            Text(" Obtained by completing quests of various types of difficulty.").font(.firaSans(s: 14))
            
            Text("Rumors say that these are the currency of an up and coming region to be explored.")
                .font(.firaSans(s: 14))
        }
        .foregroundColor(.black)
        .padding()
        .background(Color(red: 0.8, green: 0.7, blue: 0.9)) // Changed background color to absolute light purple
        .cornerRadius(12)
        .overlay(
            Triangle()
                .fill(Color(red: 0.8, green: 0.7, blue: 0.9)) // Changed triangle fill color to match bubble
                .frame(width: 20, height: 10)
                .offset(x: -99, y: -10), // Adjusted x offset to align with coin pouch
            alignment: .top // Align arrow to top of the bubble content
        )
        .shadow(radius: 0)
        .frame(maxWidth: 260) // Adjusted max width to 260 from example
        .fixedSize(horizontal: false, vertical: true) // Allow text to wrap and expand vertically
    }
}

// Supporting Views
struct StatView: View {
    let value: String
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.black)
            Text(title)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ActivityRow: View {
    let icon: String
    let title: String
    let time: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.yellow)
                .frame(width: 32, height: 32)
                .background(Color(.systemGray6).opacity(0.5))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(.black)
                Text(time)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))      // Top center
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))   // Bottom right
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))   // Bottom left
        path.closeSubpath()
        return path
    }
}

#Preview {
    NavigationView {
        ProfileView(userProfile: UserProfile(displayedName: "John Doe", username: "johndoe", avatarUrl: "https://via.placeholder.com/150"))
    }
}

