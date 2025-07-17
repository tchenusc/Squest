import SwiftUI

struct LeadershipView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Top Performers")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)) {
                    ForEach(1...5, id: \.self) { rank in
                        HStack {
                            Text("\(rank)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 24))
                            
                            VStack(alignment: .leading) {
                                Text("Player \(rank)")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                Text("\(1000 - (rank * 100)) points")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 20))
                                .foregroundColor(rank == 1 ? .yellow : .gray)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Leaderboard")
        }
    }
}

#Preview {
    LeadershipView()
} 
