//
//  TaskDetailView.swift
//  TaskApp
//
//  Created by Aula03 on 22/10/25.
//

import SwiftUI

struct TaskDetailView: View {
    @Binding var habit : Habit
    var body: some View {
        Form() {
            TextField("Título del hábito", text : $habit.title)
        }.navigationTitle($habit.title)
        
    }
}
