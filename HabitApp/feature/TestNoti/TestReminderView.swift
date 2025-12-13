//
//  TestReminderView.swift
//  HabitApp
//
//  Created by Aula03 on 22/11/25.
//

import SwiftUI
import UserNotifications

struct TestReminderView: View {
    @State private var authStatus: UNAuthorizationStatus = .notDetermined
    @State private var message = "Listo para probar"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Test Notificaciones")
                .font(.title2)
            
            Text("Estado: \(statusText)")
                .foregroundColor(authStatus == .authorized ? .green : .red)
            
            Text(message)
                .padding()
            
            Button("Solicitar Permisos") {
                requestPermissions()
            }
            
            Button("Notificación en 5s") {
                scheduleTestNotification(seconds: 5)
            }
            .disabled(authStatus != .authorized)
            
            Button("Notificación en 10s") {
                scheduleTestNotification(seconds: 10)
            }
            .disabled(authStatus != .authorized)
            
            Button("Ver Pendientes") {
                checkPendingNotifications()
            }
        }
        .padding()
        .onAppear {
            checkAuthStatus()
        }
    }
    
    private var statusText: String {
        switch authStatus {
        case .authorized: return "Autorizado ✅"
        case .denied: return "Denegado ❌"
        case .notDetermined: return "No determinado ⚠️"
        case .provisional: return "Provisional 📱"
        case .ephemeral: return "Efímero ⏰"
        @unknown default: return "Desconocido ❓"
        }
    }
    
    private func checkAuthStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                authStatus = settings.authorizationStatus
            }
        }
    }
    
    private func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    authStatus = .authorized
                    message = "Permisos concedidos ✅"
                } else {
                    authStatus = .denied
                    message = "Permisos denegados ❌"
                }
            }
        }
    }
    
    private func scheduleTestNotification(seconds: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Test Notificación"
        content.body = "Esta es una prueba de notificación después de \(seconds) segundos"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let request = UNNotificationRequest(identifier: "test-\(UUID().uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    message = "Error: \(error.localizedDescription)"
                } else {
                    message = "Notificación programada para \(seconds)s ⏰"
                }
            }
        }
    }
    
    private func checkPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                message = "Pendientes: \(requests.count)"
                for request in requests {
                    print("📱 \(request.identifier): \(request.content.title)")
                }
            }
        }
    }
}
