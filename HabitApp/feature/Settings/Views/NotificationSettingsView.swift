import SwiftUI

struct NotificationSettingsView: View {
    @State private var enableNotifications = true
    @State private var notificationTime = Date()
    
    var body: some View {
        #if os(iOS)
        iosBody
        #else
        macBody
        #endif
    }
}

// MARK: - iOS UI
#if os(iOS)
extension NotificationSettingsView {
    var iosBody: some View {
        Form {
            Section("Configuración de Recordatorios") {
                Toggle("Habilitar notificaciones", isOn: $enableNotifications)
                
                if enableNotifications {
                    DatePicker("Hora de recordatorio", selection: $notificationTime, displayedComponents: .hourAndMinute)
                }
            }
        }
        .navigationTitle("Notificaciones")
        .navigationBarTitleDisplayMode(.inline)
    }
}
#endif

// MARK: - macOS UI
#if os(macOS)
extension NotificationSettingsView {
    var macBody: some View {
        VStack(spacing: 20) {
            Form {
                Section("Configuración de Recordatorios") {
                    Toggle("Habilitar notificaciones", isOn: $enableNotifications)
                    
                    if enableNotifications {
                        DatePicker("Hora de recordatorio", selection: $notificationTime, displayedComponents: .hourAndMinute)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Notificaciones")
        .frame(minWidth: 300, minHeight: 200)
    }
}
#endif