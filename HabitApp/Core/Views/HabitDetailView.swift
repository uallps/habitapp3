//
//  TaskDetailView.swift
//  TaskApp
//
//  Created by Aula03 on 22/10/25.
//

import SwiftUI

struct HabitDetailView: View {
    @Binding var habit : Habit
    var onSave: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    
    @EnvironmentObject private var AppConfig: AppConfig
    
    var body: some View {
        Form {
            TextField("Título del hábito", text: $habit.title)
            Section(header: Text("Detalles del habito")) {
                Toggle(isOn: $habit.isCompleted) {
                    Text("Completada")
                }
                if AppConfig.showDueDates {
                    Toggle(isOn: Binding(
                        get: { habit.dueDate != nil },
                        set: { newValue in
                            if newValue {
                                habit.dueDate = Date()
                            } else {
                                habit.dueDate = nil
                            }
                        }
                    )) {
                        Text("Vencimiento")
                    }
                    if let dueDate = habit.dueDate {
                        DatePicker("Fecha de Vencimiento", selection: Binding(
                            get: { dueDate },
                            set: { habit.dueDate = $0 }
                        ), displayedComponents: .date)
                    }
                }
                if AppConfig.showPriorities {
                    Picker("Prioridad", selection: Binding(
                        get: { habit.priority },
                        set: { habit.priority = $0 }
                    )) {
                        Text("Ninguna").tag(nil as Priority?)
                        Text("Baja").tag(Priority.low)
                        Text("Media").tag(Priority.medium)
                        Text("Alta").tag(Priority.high)
                    }
                }
                if AppConfig.enableReminders {
                    Toggle(isOn: Binding(
                        get: { habit.reminderDate != nil },
                        set: { newValue in
                            if newValue {
                                habit.reminderDate = Date()
                            } else {
                                habit.reminderDate = nil
                            }
                        }
                    )) {
                        Text("Recordatorio")
                    }
                    if let reminderDate = habit.reminderDate {
                        DatePicker("Fecha de Recordatorio", selection: Binding(
                            get: { reminderDate },
                            set: { habit.reminderDate = $0 }
                        ), displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                // DatePicker( "Selecciona fecha", selection: $selectedDate, displayedComponents: [.date] )
                //     .datePickerStyle(.graphical)
                //     .onChange(of: selectedDate) { newValue in
                //         let calendar = Day.calendar
                //         if let day = Day.DayOfMonth(calendar.component(.day, from: newValue)),
                //            let month = Day.MonthOfYear(calendar.component(.month, from: newValue)) {
                //             let year = Day.Year(calendar.component(.year, from: newValue))
                //             let newDay = Day(day: day, month: month, year: year)
                //             if !habit.doneDays.contains(newDay) {
                //                 habit.doneDays.append(newDay)
                //             }
                //         }
                //     }
                
                
                CustomCalendarView(selectedDate: $selectedDate, doneDays: habit.doneDays)
                    .navigationTitle(habit.title)
                    .onChange(of: selectedDate) { oldValue, newValue in
                        let calendar = Day.calendar
                        if let day = Day.DayOfMonth(calendar.component(.day, from: newValue)),
                           let month = Day.MonthOfYear(calendar.component(.month, from: newValue)) {
                            let year = Day.Year(calendar.component(.year, from: newValue))
                            let newDay = Day(day: day, month: month, year: year)
                            if !habit.doneDays.contains(newDay) {
                                habit.doneDays.append(newDay)
                            }
                        }
                    }
                    .navigationTitle($habit.title)
                    .onDisappear {
                        onSave?()
                    }
            }
        }
        Spacer()
    }
}

#Preview {
    HabitDetailView(habit: .constant(Habit(title: "Ejemplo de Habito", isCompleted: false, dueDate: Date(), priority: .high)))
}
