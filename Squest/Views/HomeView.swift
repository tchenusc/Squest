import SwiftUI
import CoreData

/// Main view for displaying and managing quests
struct HomeView: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - State
    @StateObject private var viewModel: HomeViewModel

    // MARK: - Initialization
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(viewContext: context))
    }

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HomeHeaderView()
            
            Text("Available Quests")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .padding(.horizontal, 20)

            ScrollView {
                VStack(spacing: 20) {
                    ForEach(viewModel.sortedQuests) { quest in
                        QuestRowView(
                            quest: quest,
                            inProgressQuestId: viewModel.inProgressQuestId,
                            isPressed: viewModel.pressedQuestID == quest.id,
                            onTap: {
                                viewModel.selectQuest(quest.id)
                            }
                        )
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in viewModel.setPressedQuestID(quest.id) }
                                .onEnded { _ in viewModel.setPressedQuestID(nil) }
                        )
                        #if os(macOS)
                        .onHover { hovering in
                            viewModel.setPressedQuestID(hovering ? quest.id : nil)
                        }
                        #endif
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 24)
            }
        }
        .background(Color(.systemGray6).opacity(0.5).ignoresSafeArea())
        .sheet(isPresented: $viewModel.showDetail) {
            if let index = viewModel.quests.firstIndex(where: { $0.id == viewModel.selectedQuestID }) {
                DetailedQuestView(quest: viewModel.quests[index]) {
                    viewModel.dismissDetail()
                }
            }
        }
        .onAppear {
            viewModel.checkInProgressQuest()
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView(context: PersistenceController.preview.container.viewContext)
}
