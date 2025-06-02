import SwiftUI

/// Header component for the home screen displaying the app title and streak count
struct HomeHeaderView: View {
    // MARK: - Body
    var body: some View {
        HStack {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.purple)
                Text("Squest")
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundColor(.purple)
            }
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("7")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
            }
            .padding(.trailing, 20)
        }
        .padding(.top, 32)
        .padding(.leading, 20)
        .padding(.bottom, 24)
    }
}

// MARK: - Preview
#Preview {
    HomeHeaderView()
} 