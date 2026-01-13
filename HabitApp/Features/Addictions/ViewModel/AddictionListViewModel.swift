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
    
    func updateAddiction(addiction: Addiction) async {
        do {
            try await storageProvider.updateAddiction(addiction: addiction)
        } catch {
            print(" Error updating Addiction: \(error)")
        }
    }
    
    func deleteAddiction(addiction: Addiction) async {
        do {
            try await storageProvider.deleteAddiction(addiction:  addiction)
        } catch {
            print(" Error deleting Addiction: \(error)")
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
    
    func relapseIncrement(addiction: Addiction) {
        Task {
            addiction.relapseCount = addiction.relapseCount + 1
            try await storageProvider.updateAddiction(addiction: addiction)
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
