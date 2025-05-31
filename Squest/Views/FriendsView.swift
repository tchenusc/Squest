import SwiftUI

struct FriendsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Online Friends")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)) {
                    ForEach(1...3, id: \.self) { index in
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading) {
                                Text("Friend \(index)")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                Text("Online")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.green)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // Message action
                            }) {
                                Image(systemName: "message.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text("All Friends")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)) {
                    ForEach(4...8, id: \.self) { index in
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                            
                            VStack(alignment: .leading) {
                                Text("Friend \(index)")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                Text("Last seen 2h ago")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // Message action
                            }) {
                                Image(systemName: "message.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Friends")
            .toolbar {
                Button(action: {
                    // Add friend action
                }) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 20))
                }
            }
        }
    }
}

#Preview {
    FriendsView()
} 