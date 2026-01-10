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
        
        Task {
            notes = try await storageProvider.loadNotes(calendar: calendar, startOfDay: startOfDay, endOfDay: endOfDay, selectedDate: selectedDate)
        }
    }
    
    func addNote(title: String, content: String) {
        Task {
            let calendar = Calendar.current
            let noteDate = calendar.startOfDay(for: selectedDate)
            let note = try await storageProvider.addNote(title: title, content: content, selectedDate: selectedDate, noteDate: noteDate)
            // Programar notificación si la nota es para una fecha futura
            let today = calendar.startOfDay(for: Date())
            if noteDate > today {
                HabitDataObserverManager.shared.notify(
                    taskId: note.id,
                    title: "Nota: \(title)",
                    date: noteDate
                )
            }
            loadNotes()
        }
    }
      
    
    func updateNote(_ note: DailyNote, title: String, content: String) {
        Task {
            note.updateContent(title: title, content: content)
            try await storageProvider.saveContext()
            loadNotes()
        }
    }
    
    func saveAndGoToNoteDate(_ note: DailyNote, title: String, content: String) {
        Task {
            note.updateContent(title: title, content: content)
            selectedDate = Calendar.current.startOfDay(for: note.date) // Ajusta la fecha al día de la nota
            try await storageProvider.saveContext()
            loadNotes()
        }
    }

    
    func deleteNote(_ note: DailyNote) {
        Task {
            try await storageProvider.deleteNote(note)
            try await storageProvider.saveContext()
            loadNotes()
        }
    }
    
    func changeDate(to date: Date) {
        let today = Calendar.current.startOfDay(for: Date())
        let maxDate = Calendar.current.date(byAdding: .month, value: 3, to: today)!

        // Limitar rango permitido
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
