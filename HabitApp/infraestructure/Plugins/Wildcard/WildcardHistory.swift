//
//  WildcardHistory.swift
//  HabitApp
//
//  Created by Assistant on 10/01/26.
//

import Foundation
import SwiftData

/// Modelo persistente que almacena el historial de hábitos comodín seleccionados.
/// Se utiliza para evitar que se repitan los mismos hábitos con demasiada frecuencia.
@Model
final class WildcardHistory {
    /// Identificador único del registro de historial.
    @Attribute(.unique) var id: UUID
    
    /// Título del hábito seleccionado.
    var habitTitle: String
    
    /// Fecha en la que se seleccionó el hábito.
    var selectedAt: Date
    
    /// ID del hábito real creado en la tabla Habits (para poder borrarlo al expirar).
    var relatedHabitId: UUID?
    
    /// Inicializa un nuevo registro de historial.
    /// - Parameters:
    ///   - habitTitle: Título del hábito.
    ///   - relatedHabitId: ID del hábito asociado (opcional).
    ///   - selectedAt: Fecha de selección (por defecto, ahora).
    init(habitTitle: String, relatedHabitId: UUID? = nil, selectedAt: Date = Date()) {
        self.id = UUID()
        self.habitTitle = habitTitle
        self.relatedHabitId = relatedHabitId
        self.selectedAt = selectedAt
    }
}
