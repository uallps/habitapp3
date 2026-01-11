import Foundation
import SwiftData
import Combine

final class AddictionListViewModel: ObservableObject {
    let storageProvider: StorageProvider
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
    }
    
    func addAddiction(addiction: Addiction) async {
        do {
            try await storageProvider.addAddiction(addiction: addiction)
        } catch {
            print(" Error saving Addiction: \(error)")
        }
    }
    
    func isHabitAddiction(habit: Habit) async -> Bool {
        var isHabitAddiction = false
        do {
            isHabitAddiction = try await storageProvider.isHabitAddiction(habit: habit)
        } catch {
            print("Error checking if habit is addiction \(error)")
        }
        return isHabitAddiction
    }
    
    func updateAddiction(addiction: Addiction) async {
        do {
            try await storageProvider.updateAddiction(addiction: addiction)
        } catch {
            print(" Error updating Addiction: \(error)")
        }
    }
    
    func toggleCompletion(Addiction: Addiction, for date: Date = Date()) {
        // if Addiction.isCompletedForDate(date) {
        //     Addiction.markAsIncomplete(for: date)
        // } else {
        //     Addiction.markAsCompleted(for: date)
        // }
        
        // do {
        //     try storageProvider.context.save()
        //     print(" Hábito '\(Addiction.title)' guardado - Días completados: \(Addiction.doneDates.count)")
            
        //     //  Esperar a que SwiftData sincronice completamente
        //     DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        //         PluginRegistry.shared.notifyDataChanged(
        //             taskId: Addiction.id,
        //             title: Addiction.title,
        //             dueDate: Addiction.dueDate
        //         )
        //     }
        // } catch {
        //     print(" Error saving Addiction: \(error)")
        // }
    }
    
    func deleteAddiction(addiction: Addiction) async {
        do {
            try await storageProvider.deleteAddiction(addiction:  addiction)
        } catch {
            print(" Error deleting Addiction: \(error)")
        }
    }
    
    func createSampleAddictions() {
        // let sampleAddictions = [
        //     Addiction(title: "Fumar", priority: .high, scheduledDays: [1,  3, 4,  6, 7]),
        //     Addiction(title: "Comer chocolate", priority: .medium, scheduledDays: [ 2,  4, 5,  7]),
        //     Addiction(title: "Doomscrolling", priority: .low, scheduledDays: [1, 2,  5, 6, 7])
        // ]

        // do {
        //     for Addiction in sampleAddictions {
        //         Task {
        //             await addAddiction(Addiction)
        //         }
        //     }
        // }catch {
        //     print(" Error creating sample Addictions: \(error)")
        // }
        

    }

    func addCompensatoryHabit(
        to addiction: Addiction,
        habit: Habit
    ) async {
        do {
            try await storageProvider.addCompensatoryHabit(
                to: addiction,
                habit: habit
            )
        } catch {
            print(" Error adding compensatory habit: \(error)")
        }
    }

    func addPreventionHabit(
        to addiction: Addiction,
        habit: Habit
    ) async {
        do {
            try await storageProvider.addPreventionHabit(
                to: addiction,
                habit: habit
            )
        } catch {
            print(" Error adding prevention habit: \(error)")
        }
    }

    func addTriggerHabit(
        to addiction: Addiction,
        habit: Habit
    ) async {
        do {
            try await storageProvider.addTriggerHabit(
                to: addiction,
                habit: habit
            )
        } catch {
            print(" Error adding trigger habit: \(error)")
        }
    }


    func removeCompensatoryHabit(
        from addiction: Addiction,
        habit: Habit
    ) async {
        do {
            try await storageProvider.removeCompensatoryHabit(
                from: addiction,
                habit: habit
            )
        } catch {
            print(" Error removing compensatory habit: \(error)")
        }
    }

    func removePreventionHabit(
        from addiction: Addiction,
        habit: Habit
    ) async {
        do {
            try await storageProvider.removePreventionHabit(
                from: addiction,
                habit: habit
            )
        } catch {
            print(" Error removing prevention habit: \(error)")
        }
    }

    func removeTriggerHabit(
        from addiction: Addiction,
        habit: Habit
    ) async {
        do {
            try await storageProvider.removeTriggerHabit(
                from: addiction,
                habit: habit
            )
        } catch {
            print(" Error removing trigger habit: \(error)")
        }
    }

    func associateCompensatoryHabit(
        to addiction: Addiction,
        habit: Habit
    ) async {
        do {
            try await storageProvider.associateCompensatoryHabit(
                to: addiction,
                habit: habit
            )
        } catch {
            print(" Error associating compensatory habit: \(error)")
        }
    }

    func associatePreventionHabit(
        to addiction: Addiction,
        habit: Habit
    ) async {
        do {
            try await storageProvider.associatePreventionHabit(
                to: addiction,
                habit: habit
            )
        } catch {
            print(" Error associating prevention habit: \(error)")
        }
    }

    func associateTriggerHabit(
        to addiction: Addiction,
        habit: Habit
    ) async {
        do {
            try await storageProvider.associateTriggerHabit(
                to: addiction,
                habit: habit
            )
        } catch {
            print(" Error associating trigger habit: \(error)")
        }
    }

}
