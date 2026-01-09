import Foundation

struct Habit: Identifiable, Hashable{
    let id = UUID()
    var title: String
    var doneDays: [Day]
    var isCompleted: Bool = false
    var dueDate: Date?
    var priority: Priority?
    var reminderDate: Date?
    var scheduledDays: [Int] = [] // 1 = Domingo, 2 = Lunes, ..., 7 = Sábado

    init(title: String,
         doneDays: [Day] = [],
         isCompleted: Bool = false,
         dueDate: Date? = nil,
         priority: Priority? = nil,
         reminderDate: Date? = nil,
         scheduledDays: [Int] = []) {
        self.title = title
        self.doneDays = doneDays
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.priority = priority
        self.reminderDate = reminderDate
        self.scheduledDays = scheduledDays

    }
}
