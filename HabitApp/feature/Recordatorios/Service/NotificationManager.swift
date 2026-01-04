//
//  NotificationManager.swift
//  HabitApp
//
//  Created by Aula03 on 4/1/26.
//

import UserNotifications
import Foundation

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting auth: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func scheduleNotification(id: String, title: String, date: Date) {
        // 1. Clean previous to avoid duplicates
        removeNotification(id: id)
        
        // 2. Content
        let content = UNMutableNotificationContent()
        content.title = "Recordatorio" // Puede ser localización
        content.body = "Time to: \(title)"
        content.sound = .default
        
        // 3. Trigger (Daily)
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // 4. Request
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule: \(error.localizedDescription)")
            } else {
                print("🔔 Notification scheduled for: \(components.hour ?? 0):\(components.minute ?? 0)")
            }
        }
    }
    
    func removeNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}
