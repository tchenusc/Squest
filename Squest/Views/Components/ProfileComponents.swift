import SwiftUI

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
        .background(Color(red: 0.8, green: 0.7, blue: 0.9))
        .cornerRadius(12)
        .overlay(
            Triangle()
                .fill(Color(red: 0.8, green: 0.7, blue: 0.9))
                .frame(width: 20, height: 10)
                .offset(x: -99, y: -10),
            alignment: .top
        )
        .shadow(radius: 0)
        .frame(maxWidth: 260)
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
} 