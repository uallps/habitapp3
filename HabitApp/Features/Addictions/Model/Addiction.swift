import Foundation
import SwiftData

@Model
class Addiction: Habit {
    // Describe la gravedad de la adicción
    var severity: AddictionSeverity

    // Un triggers son hábitos que pueden provocar la recaída, pues son situaciones, emociones o entornos que aumentan el deseo de consumir la sustancia o realizar el comportamiento adictivo.
    // Deben ser por tanto, evitados o gestionados cuidadosamente.
    var triggers: [Habit]

    // Hábitos para evitar la adicción
    var preventionHabits: [Habit]
    // Hábitos para aliviar los efectos negativos en caso de recaída
    var compensatoryHabits: Habit
    
    // Número de veces que el usuario ha recaído en la adicción
    var relapseCount: Int = 0

    
    // Optional initializer to add extra fields
    init(title: String,
         severity: AddictionSeverity = .medium,
         triggers: [Habit] = [],
         preventionHabits: [Habit] = [],
         compensatoryHabits: [Habit] = [],
         doneDates: [Date] = [],
         isCompleted: Bool = false,
         dueDate: Date? = nil,
         priority: Priority? = nil,
         reminderDate: Date? = nil,
         scheduledDays: [Int] = []) {
        
        self.severity = severity
        self.triggers = triggers
        super.init(title: title,
                   doneDates: doneDates,
                   isCompleted: isCompleted,
                   dueDate: dueDate,
                   priority: priority,
                   reminderDate: reminderDate,
                   scheduledDays: scheduledDays)
    }

    enum AddictionSeverity: String {
        low, medium, high
    }
}
