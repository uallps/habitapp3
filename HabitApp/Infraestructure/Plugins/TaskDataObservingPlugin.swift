//
//  TaskDataObservingPlugin.swift
//  HabitApp
//
//  Created by Aula03 on 22/11/25.
//


import Foundation

/// Protocolo para plugins que observan cambios en datos (habit o nota)
protocol TaskDataObservingPlugin {
    /// Se llama cuando un “task” (nota o hábito) cambia o se crea
    /// - Parameters:
    ///   - taskId: UUID de la nota o hábito
    ///   - title: Título del item
    ///   - dueDate: Fecha opcional asociada al item
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?)
}
