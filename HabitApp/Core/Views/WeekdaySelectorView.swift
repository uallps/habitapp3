//
//  WeekdaySelector.swift
//  HabitApp
//
//  Created by Aula03 on 5/11/25.
//

import SwiftUI

struct WeekdaySelector: View {
    @Binding var selectedDays: [Int]
    @EnvironmentObject private var userPreferences: UserPreferences
    private let weekdays = Calendar.current.shortStandaloneWeekdaySymbols
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(1...7, id: \.self) { index in
                let isSelected = selectedDays.contains(index)
                Button(action: {
                    if isSelected {
                        selectedDays.removeAll { $0 == index }
                    } else {
                        selectedDays.append(index)
                    }
                }) {
                    Text(weekdays[index - 1].prefix(2))
                        .fontWeight(.semibold)
                        .frame(width: 36, height: 36)
                        .background(isSelected ? userPreferences.accentColor : Color.gray.opacity(0.2))
                        .foregroundColor(isSelected ? .white : .primary)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}
