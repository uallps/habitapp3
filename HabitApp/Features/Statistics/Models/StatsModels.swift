import Foundation

// MARK: - Time Range

enum TimeRange: String, CaseIterable {
    case day = "Hoy"
    case week = "Semana"
}

// MARK: - Period Data

struct PeriodData: Identifiable {
    let id = UUID()
    let label: String
    let date: Date
    let completedCount: Int
    let expectedCount: Int
    
    var completionRate: Double {
        guard expectedCount > 0 else { return 0 }
        return Double(completedCount) / Double(expectedCount)
    }
}

// MARK: - General Statistics

struct GeneralStats {
    let range: TimeRange
    let periods: [PeriodData]
    let totalCompleted: Int
    let totalExpected: Int
    
    var overallRate: Double {
        guard totalExpected > 0 else { return 0 }
        return Double(totalCompleted) / Double(totalExpected)
    }
}

// MARK: - Habit Statistics

struct HabitStats: Identifiable {
    let id: UUID
    let title: String
    let range: TimeRange
    let periods: [PeriodData]
    
    var totalCompleted: Int {
        periods.reduce(0) { $0 + $1.completedCount }
    }
    
    var totalExpected: Int {
        periods.reduce(0) { $0 + $1.expectedCount }
    }
    
    var overallRate: Double {
        guard totalExpected > 0 else { return 0 }
        return Double(totalCompleted) / Double(totalExpected)
    }
}
