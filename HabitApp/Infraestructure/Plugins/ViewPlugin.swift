import Foundation
import SwiftUI

/// Protocol para plugins que proveen vistas en diferentes puntos de la aplicación
protocol ViewPlugin: FeaturePlugin {
    /// Tipo asociado para la vista de fila que provee el plugin
    associatedtype RowContent: View
    
    /// Tipo asociado para la vista de detalle que provee el plugin
    associatedtype DetailContent: View
    
    /// Tipo asociado para la vista de configuración que provee el plugin
    associatedtype SettingsContent: View
    
    /// Provee una vista personalizada para mostrar en la fila de tarea
    /// - Parameter task: La tarea para la cual crear la vista
    /// - Returns: Una vista usando ViewBuilder
   // @ViewBuilder
   // func taskRowView(for task: Task) -> TaskRowContent
    
    /// Provee una vista personalizada para mostrar en el detalle de tarea
    /// - Parameter task: Binding a la tarea para la cual crear la vista
    /// - Returns: Una vista usando ViewBuilder
   // @ViewBuilder
   // func taskDetailView(for task: Binding<Task>) -> TaskDetailContent
    
    /// Provee una vista de configuración para el plugin
    /// - Returns: Una vista de configuración usando ViewBuilder
    @ViewBuilder
    func settingsView() -> SettingsContent
}
