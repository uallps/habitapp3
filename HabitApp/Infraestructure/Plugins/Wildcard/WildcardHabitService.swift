
import Foundation
import SwiftData

/// Implementación concreta del proveedor de habitos comodin.
/// Gestiona una lista interna de habitos y selecciona uno aleatorio respetando las reglas de negocio.
class WildcardHabitService: WildcardHabitProvider {
    
    private struct PredefinedHabit {
        let title: String
        let priority: Priority
    }
    
    /// Lista interna de habitos posibles.
    private let availableHabits: [PredefinedHabit] = [
        PredefinedHabit(title: "Beber 2 litros de agua", priority: .medium),
        PredefinedHabit(title: "Caminar 15 minutos", priority: .medium),
        PredefinedHabit(title: "Leer un capitulo de un libro", priority: .medium),
        PredefinedHabit(title: "Meditar 10 minutos", priority: .medium),
        PredefinedHabit(title: "Comer una pieza de fruta", priority: .medium),
        PredefinedHabit(title: "Organizar el escritorio", priority: .medium),
        PredefinedHabit(title: "Llamar a un amigo o familiar", priority: .medium),
        PredefinedHabit(title: "Hacer estiramientos", priority: .medium),
        PredefinedHabit(title: "Escribir en un diario", priority: .medium),
        PredefinedHabit(title: "Recuperar horas dormidas", priority: .medium),
        PredefinedHabit(title: "Aprender una palabra nueva", priority: .medium),
        PredefinedHabit(title: "Hacer una comida saludable", priority: .medium),
        PredefinedHabit(title: "Escuchar un podcast educativo", priority: .medium),
        PredefinedHabit(title: "Usar hilo dental", priority: .medium),
        PredefinedHabit(title: "Planificar la semana siguiente", priority: .medium),
        PredefinedHabit(title: "No usar pantallas 30 min antes de dormir", priority: .medium),
        PredefinedHabit(title: "Limpiar fotos antiguas del móvil", priority: .medium),
        PredefinedHabit(title: "Revisar gastos recientes", priority: .medium),
        PredefinedHabit(title: "Tomar el sol 10 minutos", priority: .medium),
        PredefinedHabit(title: "Aplicar crema hidratante", priority: .medium),
        PredefinedHabit(title: "Ordenar bandeja de entrada", priority: .medium),
        PredefinedHabit(title: "Corregir la postura corporal y relajar el cuerpo", priority: .medium)

    ]
    
   
    /// - Parameter context: El contexto de SwiftData.
    /// - Returns: Un objeto `Habit` nuevo, o `nil` si no hay candidatos validos.
    func getWildcardHabit(context: ModelContext) throws -> Habit? {
        
        var descriptor = FetchDescriptor<WildcardHistory>(
            sortBy: [SortDescriptor(\.selectedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 10
        
        let history = try context.fetch(descriptor)
        let recentTitles = Set(history.map { $0.habitTitle })
        
        let finalCandidates = availableHabits.filter { !recentTitles.contains($0.title) }
        
        let pool = finalCandidates.isEmpty ? availableHabits : finalCandidates
        
        guard let selected = pool.randomElement() else {
            return nil
        }
        
        //Crear habito
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        
        let newHabit = Habit(
            title: selected.title,
            priority: selected.priority,
            scheduledDays: [weekday]
        )
        
        // Guardar en historial con el ID del hábito real
        let newHistoryEntry = WildcardHistory(
            habitTitle: selected.title,
            relatedHabitId: newHabit.id
        )
        context.insert(newHistoryEntry)
        
        return newHabit
    }
    
    /// Limpia los hábitos comodín de días anteriores.
    /// Busca entradas en el historial cuya fecha de selección no sea hoy y elimina los hábitos correspondientes.
    func cleanupExpiredHabits(context: ModelContext) throws {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        
        // Buscar historiales creados antes de hoy
        let expiredDescriptor = FetchDescriptor<WildcardHistory>(
            predicate: #Predicate<WildcardHistory> { history in
                history.selectedAt < todayStart
            }
        )
        
        let expiredEntries = try context.fetch(expiredDescriptor)
        
        print("Buscando hábitos comodín de días anteriores: \(expiredEntries.count) encontrados.")
        
        for entry in expiredEntries {
            // Prevenir que se busquen habitos ya borrados
            if let habitId = entry.relatedHabitId {
                // Buscar el hábito real para borrarlo
                 let habitDescriptor = FetchDescriptor<Habit>(
                    predicate: #Predicate<Habit> { $0.id == habitId }
                )
                
                if let habitToDelete = try? context.fetch(habitDescriptor).first {
                     context.delete(habitToDelete)
                     print("Hábito pasado eliminado: \(habitToDelete.title)")
                }
                
                entry.relatedHabitId = nil
            }
        }
        
        // Eliminar entradas del historial de mas de 3 dias
        if let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date()) {
            let oldHistoryDescriptor = FetchDescriptor<WildcardHistory>(
                predicate: #Predicate<WildcardHistory> { $0.selectedAt < threeDaysAgo }
            )
            
            if let oldEntries = try? context.fetch(oldHistoryDescriptor) {
                 print("Eliminando historial antiguo: \(oldEntries.count) entradas.")
                 for entry in oldEntries {
                     context.delete(entry)
                 }
            }
        }
        
        try context.save()
    }
}
