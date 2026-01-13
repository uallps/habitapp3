import Foundation

extension Habit {

    /// Returns true if the given date falls on one of the habit's scheduled weekdays.
    /// - Parameter date: The date to evaluate (defaults to today).
    func isScheduled(for date: Date = Date()) -> Bool {
        guard !scheduledDays.isEmpty else { return false }

        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        // weekday: 1 = Sunday, 2 = Monday, ..., 7 = Saturday

        return scheduledDays.contains(weekday)
    }
}
