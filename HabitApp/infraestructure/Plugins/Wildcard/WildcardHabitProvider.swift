//
//  WildcardHabitProvider.swift
//  HabitApp
//
//  Created by Assistant on 10/01/26.
//

import Foundation
import SwiftData

/// Protocolo que define la interfaz para el proveedor de hábitos comodín.
/// Esto permite desacoplar la lógica de selección de hábitos del resto de la aplicación.
protocol WildcardHabitProvider {
    /// Desbloquea y devuelve un nuevo hábito comodín si es posible.
    /// - Parameter context: El contexto de SwiftData para persistencia.
    /// - Returns: Un objeto `Habit` si se encontró uno válido, o `nil` si no hay disponibles.
    func unlockWildcardHabit(context: ModelContext) throws -> Habit?
    
    /// Limpia los hábitos comodín que ya han expirado (pasada la medianoche).
    /// - Parameter context: El contexto de SwiftData.
    func cleanupExpiredHabits(context: ModelContext) throws
}
