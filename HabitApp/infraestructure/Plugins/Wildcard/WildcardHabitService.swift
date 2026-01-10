//
//  WildcardHabitService.swift
//  HabitApp
//
//  Created by Assistant on 10/01/26.
//

import Foundation
import SwiftData

/// Implementación concreta del proveedor de hábitos comodín.
/// Gestiona una lista interna de hábitos y selecciona uno aleatorio respetando las reglas de negocio.
class WildcardHabitService: WildcardHabitProvider {
    
    /// Estructura interna para definir los hábitos predefinidos disponibles.
    private struct PredefinedHabit {
        let title: String
        let priority: Priority
    }
    
    /// Lista interna de hábitos posibles.
    private let availableHabits: [PredefinedHabit] = [
        PredefinedHabit(title: "Beber 2 litros de agua", priority: .high),
        PredefinedHabit(title: "Caminar 15 minutos", priority: .medium),
        PredefinedHabit(title: "Leer un capítulo de un libro", priority: .medium),
        PredefinedHabit(title: "Meditar 10 minutos", priority: .low),
        PredefinedHabit(title: "No usar redes sociales por 1 hora", priority: .high),
        PredefinedHabit(title: "Comer una fruta", priority: .medium),
        PredefinedHabit(title: "Organizar el escritorio", priority: .low),
        PredefinedHabit(title: "Llamar a un familiar", priority: .high),
        PredefinedHabit(title: "Hacer estiramientos", priority: .medium),
        PredefinedHabit(title: "Escribir en un diario", priority: .low),
        PredefinedHabit(title: "Dormir 8 horas", priority: .high),
        PredefinedHabit(title: "Aprender una palabra nueva", priority: .low),
        PredefinedHabit(title: "Hacer la cama", priority: .medium),
        PredefinedHabit(title: "Cocinar una comida saludable", priority: .high),
        PredefinedHabit(title: "Escuchar un podcast educativo", priority: .medium)
    ]
    
    /// Desbloquea y devuelve un nuevo hábito comodín si es posible.
    ///
    /// Algoritmo:
    /// 1. Obtiene los últimos 10 hábitos comodín del historial.
    /// 2. Excluye los candidatos de la lista interna que ya están en ese historial reciente.
    /// 3. Selecciona uno al azar de los restantes.
    /// 4. Registra la selección en el historial.
    /// 5. Crea el hábito asignándolo al día actual.
    ///
    /// - Parameter context: El contexto de SwiftData.
    /// - Returns: Un objeto `Habit` nuevo, o `nil` si no hay candidatos válidos.
    func unlockWildcardHabit(context: ModelContext) throws -> Habit? {
        // 1. Obtener historial reciente (últimos 10)
        var descriptor = FetchDescriptor<WildcardHistory>(
            sortBy: [SortDescriptor(\.selectedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 10
        
        let history = try context.fetch(descriptor)
        let recentTitles = Set(history.map { $0.habitTitle })
        
        // 2. Filtrar candidatos que no estén en el historial reciente
        let finalCandidates = availableHabits.filter { !recentTitles.contains($0.title) }
        
        // Si todos los candidatos están en el historial (caso borde), 
        // usamos la lista completa para no bloquear al usuario.
        let pool = finalCandidates.isEmpty ? availableHabits : finalCandidates
        
        guard let selected = pool.randomElement() else {
            return nil
        }
        
        // 3. Crear y devolver el Hábito para el día actual
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        
        let newHabit = Habit(
            title: selected.title,
            priority: selected.priority,
            scheduledDays: [weekday]
        )
        
        // 4. Guardar en historial con el ID del hábito real
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
        
        print("🧹 Buscando hábitos comodín de días anteriores: \(expiredEntries.count) encontrados.")
        
        for entry in expiredEntries {
            if let habitId = entry.relatedHabitId {
                // Buscar el hábito real para borrarlo
                 let habitDescriptor = FetchDescriptor<Habit>(
                    predicate: #Predicate<Habit> { $0.id == habitId }
                )
                
                if let habitToDelete = try? context.fetch(habitDescriptor).first {
                     context.delete(habitToDelete)
                     print("🗑️ Hábito pasado eliminado: \(habitToDelete.title)")
                }
                
                // Limpiamos el ID para saber que ya fue procesado y no intentar borrarlo de nuevo
                entry.relatedHabitId = nil
            }
        }
        
        try context.save()
    }
}
