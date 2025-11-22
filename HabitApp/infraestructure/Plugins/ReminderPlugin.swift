//
//  Untitled.swift
//  HabitApp
//
//  Created by Aula03 on 22/11/25.
//

import SwiftUI
import UserNotifications

struct ReminderPlugin: TaskDataObservingPlugin {
    
    // Este método se llama cada vez que hay un cambio en los datos
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        guard let dueDate else { return }
        scheduleNotification(title: title, date: dueDate)
    }
    
    private func scheduleNotification(title: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Recordatorio"
        content.body = title
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(date.timeIntervalSinceNow, 1),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error programando recordatorio: \(error)")
            }
        }
    }
}
