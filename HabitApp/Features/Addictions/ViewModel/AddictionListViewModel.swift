import Foundation
import SwiftData
import Combine

final class AddictionListViewModel: ObservableObject {
    private let storageProvider: StorageProvider
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
    }
    
    func addAddiction(_Addiction: Addiction) async {        
        do {
            try await storageProvider.addAddiction(_Addiction)
        } catch {
            print(" Error saving Addiction: \(error)")
        }
    }
    
    func updateAddiction(_ Addiction: Addiction) async {
        do {
            try await storageProvider.updateAddiction(Addiction)
        } catch {
            print(" Error updating Addiction: \(error)")
        }
    }
    
    func toggleCompletion(Addiction: Addiction, for date: Date = Date()) {
        if Addiction.isCompletedForDate(date) {
            Addiction.markAsIncomplete(for: date)
        } else {
            Addiction.markAsCompleted(for: date)
        }
        
        do {
            try storageProvider.context.save()
            print(" Hábito '\(Addiction.title)' guardado - Días completados: \(Addiction.doneDates.count)")
            
            //  Esperar a que SwiftData sincronice completamente
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                PluginRegistry.shared.notifyDataChanged(
                    taskId: Addiction.id,
                    title: Addiction.title,
                    dueDate: Addiction.dueDate
                )
            }
        } catch {
            print(" Error saving Addiction: \(error)")
        }
    }
    
    func deleteAddiction(_ Addiction: Addiction) async {        
        do {
            try await storageProvider.deleteAddiction(Addiction)
        } catch {
            print(" Error deleting Addiction: \(error)")
        }
    }
    
    func createSampleAddictions() {
        let sampleAddictions = [
            Addiction(title: "Fumar", priority: .high, scheduledDays: [1,  3, 4,  6, 7]),
            Addiction(title: "Comer chocolate", priority: .medium, scheduledDays: [ 2,  4, 5,  7]),
            Addiction(title: "Doomscrolling", priority: .low, scheduledDays: [1, 2,  5, 6, 7])
        ]

        do {
            for Addiction in sampleAddictions {
                Task {
                    await addAddiction(Addiction)
                }
            }
        }catch {
            print(" Error creating sample Addictions: \(error)")
        }
        

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
            try storageProvider.removeCompensatoryHabit(
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
            try storageProvider.removePreventionHabit(
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
            try storageProvider.removeTriggerHabit(
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
            try storageProvider.associateCompensatoryHabit(
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
            try storageProvider.associatePreventionHabit(
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
            try storageProvider.associateTriggerHabit(
                to: addiction,
                habit: habit
            )
        } catch {
            print(" Error associating trigger habit: \(error)")
        }
    }

    func associateCompensatoryHabit(
        to addiction: Addiction,
        habit: Habit
    ) async {
        do {
            try storageProvider.associateCompensatoryHabit(
                to: addiction,
                habit: habit
            )
        } catch {
            print(" Error associating compensatory habit: \(error)")
        }
    }

}