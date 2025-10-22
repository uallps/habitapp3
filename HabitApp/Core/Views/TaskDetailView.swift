//
//  TaskDetailView.swift
//  TaskApp
//
//  Created by Aula03 on 22/10/25.
//

import SwiftUI

struct TaskDetailView: View {
    @Binding var habit : Habit
    @State private var selectedDate = Date()
    
    var body: some View {
        Form {
            TextField("Título del hábito", text: $habit.title)
            
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
            
        }
    }
}
