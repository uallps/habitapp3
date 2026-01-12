import SwiftUI
import SwiftData

struct StreakBadgeView: View {
    let habitId: UUID
    @Environment(\.modelContext) private var environmentContext
    @State private var streak: Streak?
    @State private var timer: Timer?
    
    private var modelContext: ModelContext {
        // Usar el contexto del environment si está disponible, sino el compartido
        if let envContext = environmentContext as? ModelContext {
            return envContext
        }
        return SwiftDataContext.shared ?? environmentContext
    }
    
    var body: some View {
        let _ = print("🔍 StreakBadgeView rendering - habitId: \(habitId), streak: \(streak?.currentCount ?? -1)")
        
        if let streak = streak, streak.currentCount > 0 {
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
        .onAppear {
            loadStreak()
            // Recargar cada 2 segundos para detectar cambios
            timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                loadStreak()
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func loadStreak() {
        let predicate = #Predicate<Streak> { $0.habitId == habitId }
        let descriptor = FetchDescriptor<Streak>(predicate: predicate)
        
        do {
            let streaks = try modelContext.fetch(descriptor)
            if let foundStreak = streaks.first {
                if streak?.currentCount != foundStreak.currentCount {
                    streak = foundStreak
                    print("✅ StreakBadgeView loaded streak - habitId: \(habitId), count: \(foundStreak.currentCount)")
                }
            } else {
                if streak != nil {
                    print("⚠️ StreakBadgeView - No streak found for habitId: \(habitId)")
                    streak = nil
                }
            }
        } catch {
            print("❌ StreakBadgeView error loading streak: \(error)")
        }
    }
}
