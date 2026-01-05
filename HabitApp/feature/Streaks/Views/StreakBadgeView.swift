import SwiftUI
import SwiftData

struct StreakBadgeView: View {
    @Query private var streaks: [Streak]
    
    init(habitId: UUID) {
        let predicate = #Predicate<Streak> { $0.habit?.id == habitId }
        _streaks = Query(filter: predicate)
    }

    var body: some View {
        if let streak = streaks.first, streak.currentCount > 0 {
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .symbolEffect(.bounce, value: streak.currentCount)
                
                Text("\(streak.currentCount)")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
    }
}
