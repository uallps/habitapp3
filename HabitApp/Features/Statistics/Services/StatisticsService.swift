import Foundation

final class StatisticsService {
    private let calendar = Calendar.current
    
    // MARK: - General Statistics
    
    func computeGeneralStats(from habits: [Habit], range: TimeRange) -> GeneralStats {
        let periods = buildPeriods(for: range)
        var aggregatedPeriods: [PeriodData] = []
        
        for period in periods {
            var totalCompleted = 0
            var totalExpected = 0
            
            for habit in habits {
                let completed = countCompletions(in: habit, on: period.date)
                let expected = countExpected(in: habit, on: period.date)
                totalCompleted += completed
                totalExpected += expected
            }
            
            let periodData = PeriodData(
                label: period.label,
                date: period.date,
                completedCount: totalCompleted,
                expectedCount: totalExpected
            )
            aggregatedPeriods.append(periodData)
        }
        
        // Total completados y esperados del período (día o semana actual)
        let totalCompleted = aggregatedPeriods.reduce(0) { $0 + $1.completedCount }
        let totalExpected = aggregatedPeriods.reduce(0) { $0 + $1.expectedCount }
        
        return GeneralStats(
            range: range,
            periods: aggregatedPeriods,
            totalCompleted: totalCompleted,
            totalExpected: totalExpected
        )
    }
    
    // MARK: - Per-Habit Statistics
    
    func computeHabitStats(for habit: Habit, range: TimeRange) -> HabitStats {
        let periods = buildPeriods(for: range)
        var habitPeriods: [PeriodData] = []
        
        for period in periods {
            let completed = countCompletions(in: habit, on: period.date)
            let expected = countExpected(in: habit, on: period.date)
            
            let periodData = PeriodData(
                label: period.label,
                date: period.date,
                completedCount: completed,
                expectedCount: expected
            )
            habitPeriods.append(periodData)
        }
        
        return HabitStats(
            id: habit.id,
            title: habit.title,
            range: range,
            periods: habitPeriods
        )
    }
    
    // MARK: - Helpers
    
    private func buildPeriods(for range: TimeRange) -> [(label: String, date: Date)] {
        let today = calendar.startOfDay(for: Date())
        var periods: [(String, Date)] = []
        
        switch range {
        case .day:
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            periods.append((formatter.string(from: today), today))
            
        case .week:
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE d"
            
            // Generar la semana actual (Dom-Sáb) usando la misma lógica que HabitListView
            let todayWeekday = calendar.component(.weekday, from: today)
            for weekday in 1...7 {
                let diff = weekday - todayWeekday
                if let date = calendar.date(byAdding: .day, value: diff, to: today) {
                    let label = formatter.string(from: date)
                    periods.append((label, date))
                }
            }
        }
        
        return periods
    }
    
    private func countCompletions(in habit: Habit, on date: Date) -> Int {
        let targetDate = calendar.startOfDay(for: date)
        return habit.doneDates.contains { calendar.isDate($0, inSameDayAs: targetDate) } ? 1 : 0
    }
    
    private func countExpected(in habit: Habit, on date: Date) -> Int {
        let weekday = calendar.component(.weekday, from: date)
        return habit.scheduledDays.contains(weekday) ? 1 : 0
    }
}
