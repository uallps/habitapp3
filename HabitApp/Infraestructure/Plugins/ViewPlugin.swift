//
//  ViewPlugin.swift
//  TaskApp
//
//  Created by Francisco José García García on 12/11/25.
//

import Foundation
import SwiftUI

/// Protocol para plugins que proveen vistas en diferentes puntos de la aplicación
protocol ViewPlugin: FeaturePlugin {
    /// Tipo asociado para la vista de fila que provee el plugin
    associatedtype TaskRowContent: View
    
    /// Tipo asociado para la vista de detalle que provee el plugin
    associatedtype TaskDetailContent: View
    
    /// Tipo asociado para la vista de configuración que provee el plugin
    associatedtype SettingsContent: View
    
    associatedtype SettingsView: View
    
}
