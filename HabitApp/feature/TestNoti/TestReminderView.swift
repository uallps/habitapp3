//
//  TestReminderView.swift
//  HabitApp
//
//  Created by Aula03 on 22/11/25.
//

import SwiftUI
import UIKit

struct TestReminderView: View {
    @State private var message = "Listo para probar alertas"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Test Notificaciones")
                .font(.title2)
            
            Text(message)
                .padding()
            
            Button("Test Plugin Directo") {
                testReminderPlugin()
            }
            
            Button("Alerta en 3s") {
                scheduleTestAlert(seconds: 3)
            }
            
            Button("Alerta en 5s") {
                scheduleTestAlert(seconds: 5)
            }
            
            Button("Alerta Inmediata") {
                showTestAlert()
            }
        }
        .padding()

    }
    
    private func testReminderPlugin() {
        let plugin = ReminderPlugin()
        let futureDate = Date().addingTimeInterval(3)
        
        plugin.onDataChanged(
            taskId: UUID(),
            title: "Test desde Plugin",
            dueDate: futureDate
        )
        
        message = "Plugin ejecutado - alerta en 3s ⏰"
    }
    
    private func scheduleTestAlert(seconds: Int) {
        message = "Alerta programada para \(seconds)s ⏰"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(seconds)) {
            showAlert(title: "Test Alerta", message: "Alerta después de \(seconds) segundos")
        }
    }
    
    private func showTestAlert() {
        showAlert(title: "Test Inmediato", message: "Esta es una alerta inmediata")
        message = "Alerta mostrada ✅"
    }
    
    private func showAlert(title: String, message: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("No se pudo obtener la ventana")
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let topController = window.rootViewController?.topMostViewController() {
            topController.present(alert, animated: true)
        }
    }
}
