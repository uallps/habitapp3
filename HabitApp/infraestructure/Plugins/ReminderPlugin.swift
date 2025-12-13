//
//  ReminderPlugin.swift
//  HabitApp
//
//  Created by Aula03 on 22/11/25.
//

import SwiftUI
import UIKit

struct ReminderPlugin: TaskDataObservingPlugin {
    
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        guard let dueDate else { 
            print("🔔 ReminderPlugin: No hay fecha para \(title)")
            return 
        }
        
        let timeInterval = dueDate.timeIntervalSinceNow
        print("🔔 ReminderPlugin: Programando alerta para '\(title)' en \(timeInterval)s")
        
        if timeInterval > 0 {
            scheduleAlert(title: title, delay: timeInterval)
        } else {
            showImmediateAlert(title: title)
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
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("🔔 No se pudo obtener la ventana")
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let topController = window.rootViewController?.topMostViewController() {
            topController.present(alert, animated: true)
            print("🔔 Alerta mostrada: \(message)")
        }
    }
}

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
