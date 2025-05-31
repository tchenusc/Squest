import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.blue)
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Text("John Doe")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                        
                        Text("@johndoe")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // Stats Section
                    HStack(spacing: 40) {
                        VStack {
                            Text("1,234")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            Text("Points")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("42")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            Text("Friends")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("15")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            Text("Quests")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    
                    // Achievements Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recent Achievements")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .padding(.horizontal)
                        
                        ForEach(1...3, id: \.self) { index in
                            HStack {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.yellow)
                                Text("Achievement \(index)")
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                Spacer()
                                Text("2 days ago")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                Button(action: {
                    // Edit profile action
                }) {
                    Text("Edit")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                }
            }
        }
    }
}

#Preview {
    ProfileView()
} 