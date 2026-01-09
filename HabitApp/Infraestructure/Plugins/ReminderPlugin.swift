//
//  ReminderPlugin.swift
//  HabitApp
//
//  Created by Aula03 on 22/11/25.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

class ReminderPlugin: TaskDataObservingPlugin {
    var models: [any PersistentModel.Type]
    
    var isEnabled: Bool
    
    required init(config: AppConfig) {
        self.isEnabled = AppConfig.enableReminders
        
    }
    
    
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        guard let dueDate else { 
            print("🔔 ReminderPlugin: No hay fecha para \(title)")
            return 
        }
        
        let timeInterval = dueDate.timeIntervalSinceNow
        print("🔔 ReminderPlugin: Programando alerta para '\(title)' en \(timeInterval)s")
        
        // Solo programar si es en el futuro (más de 5 segundos)
        if timeInterval > 5 {
            scheduleAlert(title: title, delay: timeInterval)
        } else {
            print("🔔 ReminderPlugin: Fecha muy cercana o pasada, no se programa alerta")
        }
    }
    
    private func scheduleAlert(title: String, delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            showAlert(title: "Recordatorio", message: title)
        }
    }
    
    private func showImmediateAlert(title: String) {
        DispatchQueue.main.async {
            showAlert(title: "Recordatorio", message: title)
        }
    }
    
    private func showAlert(title: String, message: String) {
        #if os(iOS)
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
                print("🔔 No se pudo obtener la ventana principal")
                return
            }
            
            guard let topController = window.rootViewController?.topMostViewController(),
                  topController.presentedViewController == nil else {
                print("🔔 No se puede mostrar alerta, hay otra vista presente")
                return
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            topController.present(alert, animated: true) {
                print("🔔 Alerta mostrada: \(message)")
            }
        }
        #else
        print("🔔 Alerta en macOS: \(title) - \(message)")
        #endif
    }
}

#if os(iOS)
extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? self
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? self
        }
        return self
    }
}
#endif
