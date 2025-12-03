//
//  HabitDetailWrapper.swift
//  HabitApp
//
//  Created by Aula03 on 5/11/25.
//

import SwiftUI
import SwiftData

struct HabitDetailWrapper: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: HabitListViewModel
    @State var habit: Habit
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Título del hábito", text: $habit.title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Text("Selecciona los días de la semana")
                .font(.headline)
            
            WeekdaySelector(selectedDays: $habit.scheduledDays)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                modelContext.insert(habit)
                try? modelContext.save()
                dismiss()
            }) {
                Text("Guardar hábito")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding(.horizontal)
            }
            .background(Color.blue)
            .cornerRadius(10)
        }
        .navigationTitle("Nuevo hábito")
        .padding()
    }
}
