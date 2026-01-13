import SwiftUI

struct ScoreHeaderView: View {
    let totalScore: Int
    let level: AchievementLevel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Puntuación total")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(totalScore) pts")
                    .font(.headline)
            }
            
            HStack {
                Label(level.title, systemImage: level.systemImage)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(level.color.opacity(0.15))
                    .foregroundColor(level.color)
                    .clipShape(Capsule())
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}
