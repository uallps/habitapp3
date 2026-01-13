

import Foundation
import SwiftData

protocol WildcardHabitProvider {
    
    func getWildcardHabit(context: ModelContext) throws -> Habit?
    
    func cleanupExpiredHabits(context: ModelContext) throws
}
