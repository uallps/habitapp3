import SwiftUI
import SwiftData

struct StreakBadgeView: View {
    let habitId: UUID
    @Query private var allStreaks: [Streak]
    
    private var streak: Streak? {
        allStreaks.first { $0.habitId == habitId }
    }
    
    var body: some View {
        let _ = print("🔍 StreakBadgeView rendering - habitId: \(habitId), total streaks: \(allStreaks.count), my streak: \(streak?.currentCount ?? -1)")
        
        if let streak = streak, streak.currentCount > 0 {
            let hot = streak.currentCount > 4
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .symbolRenderingMode(.multicolor)
                    .symbolEffect(.bounce, value: streak.currentCount)
                
                Text("\(streak.currentCount)")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background((hot ? Color.red : Color.orange).opacity(0.15))
            .cornerRadius(8)
            .transition(.scale.combined(with: .opacity))
        }
    }
}
