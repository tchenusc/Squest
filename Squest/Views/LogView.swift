import SwiftUI

struct LogEntry: Identifiable {
    let id = UUID()
    let message: String
    let timestamp: Date
    var icon: String? = nil
    var iconColor: Color? = nil
}

struct LogView: View {
    @State private var logEntries: [LogEntry] = [
        LogEntry(message: "Side quest 1: Morning Run started on 2024-07-20 08:00:00", timestamp: Date(), icon: "play.circle.fill", iconColor: .green),
        LogEntry(message: "Side quest 2: Digital Detox completed on 2024-07-19 22:30:00, earning rewards of 100 XP, 50 Gold", timestamp: Date().addingTimeInterval(-86400), icon: "checkmark.circle.fill", iconColor: .blue),
        LogEntry(message: "Side quest 3: Evening Walk cancelled on 2024-07-19 18:00:00", timestamp: Date().addingTimeInterval(-172800), icon: "xmark.circle.fill", iconColor: .red),
        LogEntry(message: "user friended @jamier", timestamp: Date().addingTimeInterval(-259200), icon: "person.badge.plus.fill", iconColor: .purple),
        LogEntry(message: "user leveled up to level 6, earning rewards of 200 XP, 100 Gold", timestamp: Date().addingTimeInterval(-345600), icon: "arrow.up.circle.fill", iconColor: .orange),
        LogEntry(message: "Side quest 4: Evening Yoga started on 2024-07-18 19:00:00", timestamp: Date().addingTimeInterval(-432000), icon: "play.circle.fill", iconColor: .green),
        LogEntry(message: "user friended @taylorp", timestamp: Date().addingTimeInterval(-518400), icon: "person.badge.plus.fill", iconColor: .purple),
        LogEntry(message: "Side quest 5: Read a Book completed on 2024-07-17 10:00:00, earning rewards of 50 XP, 25 Gold", timestamp: Date().addingTimeInterval(-604800), icon: "checkmark.circle.fill", iconColor: .blue)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)
                    .padding(.bottom, 12)
                
                VStack(spacing: 1) {
                    ForEach(logEntries.sorted(by: { $0.timestamp > $1.timestamp })) { entry in
                        HStack(alignment: .center, spacing: 12) {
                            if let icon = entry.icon, let color = entry.iconColor {
                                Image(systemName: icon)
                                    .font(.system(size: 18))
                                    .foregroundColor(color)
                                    .frame(width: 28, height: 28)
                                    .background(color.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            Text(entry.message)
                                .font(.system(size: 14))
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if entry.id != logEntries.sorted(by: { $0.timestamp > $1.timestamp }).last?.id {
                            Divider().padding(.leading, 42)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("Activity Log")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    NavigationView {
        LogView()
    }
} 
