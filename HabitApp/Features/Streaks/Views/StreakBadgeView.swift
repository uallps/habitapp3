import SwiftUI
import SwiftData

struct StreakBadgeView: View {
    @Query private var streaks: [Streak]
    
    init(habitId: UUID) {
        // Buscamos solo la racha de este hábito específico
        let predicate = #Predicate<Streak> { $0.habitId == habitId }
        _streaks = Query(filter: predicate)
    }
    
    var body: some View {
        if let streak = streaks.first, streak.currentCount > 0 {
            let hot = streak.currentCount > 4
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .symbolRenderingMode(.multicolor)
                    .symbolEffect(.bounce, value: streak.currentCount) // Animación al cambiar
                
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
