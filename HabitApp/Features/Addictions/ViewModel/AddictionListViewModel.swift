import Foundation
import SwiftData
import Combine

final class AddictionListViewModel: ObservableObject {
    private let storageProvider: StorageProvider
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
    }
    
    func addAddiction(title: String, 
                  dueDate: Date? = nil, 
                  priority: Priority? = nil, 
                  reminderDate: Date? = nil, 
                  scheduledDays: [Int] = []) {
        let Addiction = Addiction(
            title: title,
            dueDate: dueDate,
            priority: priority,
            reminderDate: reminderDate,
            scheduledDays: scheduledDays
        )
        storageProvider.context.insert(Addiction)
        
        do {
            try storageProvider.context.save()
            
            //  Notificar plugins si hay fecha de recordatorio
            if let reminderDate = reminderDate {
                PluginRegistry.shared.notifyDataChanged(
                    taskId: Addiction.id,
                    title: Addiction.title,
                    dueDate: reminderDate
                )
            }
        } catch {
            print(" Error saving Addiction: \(error)")
        }
    }
    
    func updateAddiction(_ Addiction: Addiction) {
        do {
            try storageProvider.context.save()
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
    
    func deleteAddiction(_ Addiction: Addiction) {
        storageProvider.context.delete(Addiction)
        
        do {
            try storageProvider.context.save()
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
        
        for Addiction in sampleAddictions {
            storageProvider.context.insert(Addiction)
        }
        
        do {
            try storageProvider.context.save()
            print(" Adicciones de muestra creados")
        } catch {
            print(" Error creating sample Addictions: \(error)")
        }
    }
    
    func scheduleAddictionsNotification(for date: Date, Addictions: [Addiction]) {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let dayAddictions = Addictions.filter { $0.scheduledDays.contains(weekday) }
        
        if !dayAddictions.isEmpty {
            let AddictionTitles = dayAddictions.map { $0.title }.joined(separator: ", ")
            let notificationDate = calendar.date(byAdding: .hour, value: 9, to: calendar.startOfDay(for: date)) ?? date
            
            PluginRegistry.shared.notifyDataChanged(
                taskId: UUID(),
                title: "Hoy tienes \(dayAddictions.count) adicción(s): \(AddictionTitles)",
                dueDate: notificationDate
            )
        }
    }
}