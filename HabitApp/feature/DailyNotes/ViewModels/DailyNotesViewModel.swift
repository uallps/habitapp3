import Foundation
import SwiftData
import Combine

final class DailyNotesViewModel: ObservableObject {
    private let storageProvider: StorageProvider
    @Published var notes: [DailyNote] = []
    @Published var selectedDate = Date()
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        loadNotes()
    }
    
    func loadNotes() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Cargamos notas que no pertenecen a un hábito específico (habitId == nil)
        let predicate = #Predicate<DailyNote> { note in
            note.date >= startOfDay && note.date < endOfDay && note.habitId == nil
        }
        
        let descriptor = FetchDescriptor<DailyNote>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            notes = try storageProvider.context.fetch(descriptor)
        } catch {
            print("Error loading notes: \(error)")
        }
    }
    
    // ✅ Añadido parámetro opcional doneDates
    func addNote(title: String, content: String, doneDates: [Date]? = nil) {
        let calendar = Calendar.current
        let noteDate = calendar.startOfDay(for: selectedDate)
        let note = DailyNote(title: title, content: content, date: noteDate)
        
        storageProvider.context.insert(note)
        saveContext()
        loadNotes()
        
        // Programar notificación si la nota es para una fecha futura
        let today = calendar.startOfDay(for: Date())
        if noteDate > today {
            // ✅ Corregido: Usamos noteDate y pasamos doneDates
            TaskDataObserverManager.shared.notify(
                taskId: note.id,
                title: "Nota: \(title)",
                date: noteDate,
                doneDates: doneDates
            )
        }
    }
      
    private func saveContext() {
        do {
            try storageProvider.context.save()
            // Forzamos que los cambios se procesen para que los plugins lean datos frescos
            storageProvider.context.processPendingChanges()
        } catch {
            print("Error guardando contexto: \(error)")
        }
    }

    func updateNote(_ note: DailyNote, title: String, content: String) {
        note.updateContent(title: title, content: content)
        saveContext()
        loadNotes()
    }
    
    func saveAndGoToNoteDate(_ note: DailyNote, title: String, content: String) {
        note.updateContent(title: title, content: content)
        selectedDate = Calendar.current.startOfDay(for: note.date)
        saveContext()
        loadNotes()
    }
    
    func deleteNote(_ note: DailyNote) {
        storageProvider.context.delete(note)
        saveContext()
        loadNotes()
    }
    
    func changeDate(to date: Date) {
        let today = Calendar.current.startOfDay(for: Date())
        let maxDate = Calendar.current.date(byAdding: .month, value: 3, to: today)!

        if date < today {
            selectedDate = today
        } else if date > maxDate {
            selectedDate = maxDate
        } else {
            selectedDate = date
        }
        loadNotes()
    }
}
