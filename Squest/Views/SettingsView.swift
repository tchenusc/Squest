import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            // Add a thin line below the navigation bar area
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color(.systemGray3))
                    .frame(height: 10.2)
                
                List {
                    Section {
                        // Log item
                        HStack {
                            Image(systemName: "doc.plaintext") // Example icon for log
                                .foregroundColor(.blue)
                            Text("Log")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        // Action can be added here if needed, e.g., using a NavigationLink or Button
                        
                        // Removed Tab item
                        // HStack {
                        //     Image(systemName: "square.on.square") // Example icon for tab
                        //         .foregroundColor(.blue)
                        //     Text("Tab")
                        //     Spacer()
                        //     Image(systemName: "chevron.right")
                        //         .foregroundColor(.secondary)
                        // }
                        // Action for tab
                        // Example: NavigationLink("", destination: SomeTabView()) // Replace SomeTabView with actual view
                    }
                }
                .padding(.top, -10) // Adjust top padding to -10
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline) // Use inline display mode for title
        }
    }
}

#Preview {
    SettingsView()
} 
