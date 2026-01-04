//
//  RecordatorioViewModel.swift
//  HabitApp
//
//  Created by Aula03 on 3/12/25.
//

import Foundation
import SwiftData
import Observation

@Observable
class RecordatorioViewModel {
    var habit: Habit
    private let notificationManager = NotificationManager.shared
    
    init(habit: Habit) {
        self.habit = habit
    }
    
    // Handles Toggle logic or Date changes
    func updateReminderStatus() {
        if habit.isReminderEnabled {
            authorizeAndSchedule()
        } else {
            cancelReminder()
        }
    }
    
    private func authorizeAndSchedule() {
        notificationManager.requestAuthorization { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                // Ensure date exists, default to now if nil
                let dateToSchedule = self.habit.reminderDate ?? Date()
                if self.habit.reminderDate == nil {
                    self.habit.reminderDate = dateToSchedule
                }
                
                // Use persistentModelID or a UUID property if available
                self.notificationManager.scheduleNotification(
                    id: self.habit.id.uuidString,
                    title: self.habit.title,
                    date: dateToSchedule
                )
            } else {
                // Revert toggle if permission denied
                self.habit.isReminderEnabled = false
            }
        }
    }
    
    private func cancelReminder() {
        notificationManager.removeNotification(id: habit.id.uuidString)
    }
}
