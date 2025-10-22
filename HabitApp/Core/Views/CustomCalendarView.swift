//
//  CustomCalendarView.swift
//  HabitApp
//
//  Created by Aula03 on 22/10/25.
//

import SwiftUI

struct CustomCalendarView: View {
    @Binding var selectedDate: Date
    let doneDays: [Day]  // Your model
    
    private let calendar = Calendar.current
    private let daysInWeek = 7
    
    // Get all days for the current month
    private var days: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate) else { return [] }
        var days: [Date] = []
        var currentDate = monthInterval.start
        
        while currentDate < monthInterval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return days
    }
    
    var body: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: daysInWeek)
        
        LazyVGrid(columns: columns) {
            ForEach(days, id: \.self) { date in
                let day = calendar.component(.day, from: date)
                
                VStack {
                    Text("\(day)")
                        .frame(width: 30, height: 30)
                        .background(
                            Circle()
                                .fill(calendar.isDate(date, inSameDayAs: selectedDate) ? Color.blue : Color.clear)
                        )
                        .overlay(
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                                .offset(x: 10, y: 10)
                                .opacity(doneDays.contains(where: { $0.isSameDay(as: date) }) ? 1 : 0)
                        )
                }
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
        .padding()
    }
}

// Extend your Day model to compare with Date
extension Day {
    func isSameDay(as date: Date) -> Bool {
        let calendar = Calendar.current
        return self.day.value == calendar.component(.day, from: date) &&
               self.month.value == calendar.component(.month, from: date) &&
               self.year.value == calendar.component(.year, from: date)
    }
}
