//
//  HabitDetailWrapper.swift
//  HabitApp
//
//  Created by Aula03 on 5/11/25.
//

import SwiftUI

struct HabitDetailWrapper: View {
    @Environment(\.dismiss) private var dismiss
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
                viewModel.addHabit(habit: habit)
                dismiss()
            }) {
                Text("Guardar hábito")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .navigationTitle("Nuevo hábito")
        .padding()
    }
}
