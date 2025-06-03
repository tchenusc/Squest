import SwiftUI

struct ProfileView: View {
    @State private var levelProgress: Double = 0.75 // Example progress value
    
    var body: some View {
        ZStack {
            ScrollView {
                // Use ZStack to layer content and the settings button
                ZStack(alignment: .topTrailing) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Profile Header
                        VStack(spacing: 16) {
                            // Avatar with shadow and border
                            ZStack {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.blue)
                            }
                            
                            // Name and Username
                            VStack(spacing: 4) {
                                Text("John Doe")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.black)
                                
                                Text("@johndoe")
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
                                Text("Level Progress")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.black)
                                
                                HStack {
                                    Text("Level 5")
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    Spacer()
                                    Text("75%")
                                        .font(.system(size: 17, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                
                                // Progress Bar
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(.systemGray5))
                                            .frame(height: 12)
                                        
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.blue)
                                            .frame(width: geometry.size.width * levelProgress, height: 12)
                                    }
                                }
                                .frame(height: 12)
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
                    
                    // NavigationLink for Settings Button positioned in top trailing corner
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.black)
                            .padding(.top, 8)
                            .padding(.trailing, 20)
                    }
                }
            }
            .background(Color(.systemGray6).opacity(0.5).ignoresSafeArea())
        }
        // Keep navigationTitle if you want the default title appearance
        // .navigationTitle("Profile")
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

#Preview {
    NavigationView {
        ProfileView()
    }
}

