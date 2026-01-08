import Foundation
import SwiftData
import Combine

final class DailyNotesViewModel: ObservableObject {
    private var modelContext: ModelContext?
    @Published var notes: [DailyNote] = []
    @Published var selectedDate = Date()
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        loadNotes()
    }
    
    func loadNotes() {
        guard let modelContext else { return }  // <--- evitar crash

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<DailyNote> { note in
            note.date >= startOfDay && note.date < endOfDay && note.habit == nil
        }
        
        let descriptor = FetchDescriptor<DailyNote>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            notes = try modelContext.fetch(descriptor)
        } catch {
            print("Error loading notes: \(error)")
        }
    }
    
    func addNote(title: String, content: String) {
        guard let modelContext else { return }  // <--- evitar crash

          let note = DailyNote(title: title, content: content, date: selectedDate)
          modelContext.insert(note)
          saveContext()
          loadNotes()
          
          // 🔔 Notificar plugins
          PluginRegistry.shared.dataObservers.forEach { plugin in
              plugin.onDataChanged(
                  taskId: note.id,
                  title: note.title,
                  dueDate: note.date
              )
          }
      }
      
      private func saveContext() {
          guard let modelContext else { return }  // <--- evitar crash

          do { try modelContext.save() }
          catch { print("Error guardando contexto: \(error)") }
      }
  

    
    func updateNote(_ note: DailyNote, title: String, content: String) {
        guard let modelContext else { return }  // <--- evitar crash

        note.updateContent(title: title, content: content)
        saveContext()
        loadNotes()
    }
    
    func saveAndGoToNoteDate(_ note: DailyNote, title: String, content: String) {
        guard let modelContext else { return }  // <--- evitar crash

        note.updateContent(title: title, content: content)
        selectedDate = Calendar.current.startOfDay(for: note.date) // Ajusta la fecha al día de la nota
        saveContext()
        loadNotes()
    }

    
    func deleteNote(_ note: DailyNote) {
        guard let modelContext else { return }  // <--- evitar crash

        modelContext.delete(note)
        saveContext()
        loadNotes()
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
