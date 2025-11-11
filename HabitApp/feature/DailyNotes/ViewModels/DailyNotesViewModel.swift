import Foundation
import SwiftData

@Observable
class DailyNotesViewModel {
    private var modelContext: ModelContext
    var notes: [DailyNote] = []
    var selectedDate = Date()
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadNotes()
    }
    
    func loadNotes() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<DailyNote> { note in
            note.date >= startOfDay && note.date < endOfDay
        }
        
        let descriptor = FetchDescriptor<DailyNote>(predicate: predicate, sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        
        do {
            notes = try modelContext.fetch(descriptor)
        } catch {
            print("Error loading notes: \(error)")
        }
    }
    
    func addNote(title: String, content: String) {
        let note = DailyNote(title: title, content: content, date: selectedDate)
        modelContext.insert(note)
        saveContext()
        loadNotes()
    }
    
    func updateNote(_ note: DailyNote, title: String, content: String) {
        note.updateContent(title: title, content: content)
        saveContext()
        loadNotes()
    }
    
    func deleteNote(_ note: DailyNote) {
        modelContext.delete(note)
        saveContext()
        loadNotes()
    }
    
    func changeDate(to date: Date) {
        selectedDate = date
        loadNotes()
    }
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}