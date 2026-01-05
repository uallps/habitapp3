//
//  NotificationManager.swift
//  HabitApp
//
//  Created by Aula03 on 4/1/26.
//


//TODO
// Hacer que con check no se dispare la notificacion del dia
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
    
    func scheduleNotification(for habit: Habit) {
        removeHabitNotifications(for: habit)
        
        guard let reminderDate = habit.reminderDate, !habit.scheduledDays.isEmpty else {
            print("Hábito '\(habit.title)' sin recordatorio o sin dias asignados.")
            return
        }
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: reminderDate)
        let minute = calendar.component(.minute, from: reminderDate)
        
        
        for weekday in habit.scheduledDays {
            let content = UNMutableNotificationContent()
            content.title = "Recordatorio: \(habit.title)"
            content.body = "¡Es hora de cumplir tu hábito!"
            content.sound = .default
            
            
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            components.weekday = weekday
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
            let uniqueID = "\(habit.id.uuidString)-\(weekday)"
            
            let request = UNNotificationRequest(identifier: uniqueID, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
    
                } else {
                    print ("Notificacion agendada correctamente")
                }
            }
        }
        
    }
    
    func removeHabitNotifications(for habit: Habit) {
        let possibleIDs = (1...7).map { "\(habit.id.uuidString)-\($0)"}
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: possibleIDs)
    }
}
