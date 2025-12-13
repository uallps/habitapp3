//
//  Untitled.swift
//  HabitApp
//
//  Created by Aula03 on 22/11/25.
//

import SwiftUI
import UserNotifications

struct ReminderPlugin: TaskDataObservingPlugin {
    
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        guard let dueDate else { 
            print("🔔 ReminderPlugin: No hay fecha para \(title)")
            return 
        }
        
        let timeInterval = dueDate.timeIntervalSinceNow
        print("🔔 ReminderPlugin: Programando notificación para '\(title)' en \(timeInterval)s")
        
        if timeInterval > 0 {
            scheduleNotification(title: title, date: dueDate, taskId: taskId)
        } else {
            print("🔔 ReminderPlugin: Fecha ya pasó, no se programa notificación")
        }
    }
    
    private func scheduleNotification(title: String, date: Date, taskId: UUID) {
        let content = UNMutableNotificationContent()
        content.title = "Recordatorio"
        content.body = title
        content.sound = .default
        content.badge = 1
        
        let timeInterval = max(date.timeIntervalSinceNow, 1)
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "reminder-\(taskId.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("🔔 Error programando recordatorio: \(error)")
            } else {
                print("🔔 Notificación programada exitosamente para \(timeInterval)s")
            }
        }
    }
}
