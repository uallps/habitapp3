import Foundation
import SwiftData

@Model
final class Streak {
    @Attribute(.unique) var id: UUID
    var currentCount: Int = 0
    var bestCount: Int = 0
    var lastUpdate: Date = Date()
    
    // RELACIÓN INVERTIDA:
    // La Feature apunta al Core. Habit no sabe que esto existe.
    @Relationship var habit: Habit?
    
    init(habit: Habit) {
        self.id = UUID()
        self.habit = habit
        self.currentCount = 0
        self.bestCount = 0
        self.lastUpdate = Date()
    }
    
    /// Método principal para recalcular la racha basándose en los datos del Core
    func update() {
        guard let habit = habit else { return }
        let dates = habit.doneDates
        
        self.currentCount = calculateCurrentStreak(from: dates)
        self.bestCount = calculateLongestStreak(from: dates)
        self.lastUpdate = Date()
    }
    
    // MARK: - Lógica de Cálculo
    
    private func calculateCurrentStreak(from dates: [Date]) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Ordenamos fechas de más reciente a más antigua
        let sortedDates = dates.map { calendar.startOfDay(for: $0) }
                             .sorted(by: >)
        
        guard !sortedDates.isEmpty else { return 0 }
        
        // Si la última vez que se hizo no fue ni hoy ni ayer, la racha es 0
        if let mostRecent = sortedDates.first {
            let diff = calendar.dateComponents([.day], from: mostRecent, to: today).day ?? 0
            if diff > 1 { return 0 }
        }
        
        var streak = 0
        var referenceDate = sortedDates.first!
        
        // Comprobamos si el primer elemento de la lista es hoy o ayer
        let firstDiff = calendar.dateComponents([.day], from: referenceDate, to: today).day ?? 0
        if firstDiff > 1 { return 0 }
        
        streak = 1
        
        // Recorremos hacia atrás buscando días consecutivos
        for i in 1..<sortedDates.count {
            let previousDate = sortedDates[i]
            let dayDifference = calendar.dateComponents([.day], from: previousDate, to: referenceDate).day ?? 0
            
            if dayDifference == 1 {
                streak += 1
                referenceDate = previousDate
            } else if dayDifference > 1 {
                break // Se rompió la racha
            }
            // Si dayDifference == 0 es un duplicado, lo saltamos
        }
        
        return streak
    }
    
    private func calculateLongestStreak(from dates: [Date]) -> Int {
        let calendar = Calendar.current
        let sortedDates = Array(Set(dates.map { calendar.startOfDay(for: $0) })).sorted()
        
        guard !sortedDates.isEmpty else { return 0 }
        
        var maxStreak = 0
        var currentStreak = 0
        var lastDate: Date?
        
        for date in sortedDates {
            if let last = lastDate,
               let nextDay = calendar.date(byAdding: .day, value: 1, to: last),
               calendar.isDate(nextDay, inSameDayAs: date) {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
            maxStreak = max(maxStreak, currentStreak)
            lastDate = date
        }
        
        return maxStreak
    }
}
