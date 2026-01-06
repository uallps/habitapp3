import SwiftUI
import SwiftData

struct AddGoalView: View {
    let habits: [Habit]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title = ""
    @State private var description = ""
    @State private var targetCount = 30
    @State private var targetDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var selectedHabit: Habit?
    @State private var milestones: [MilestoneInput] = []
    
    var body: some View {
        #if os(iOS)
        iosBody
        #else
        macBody
        #endif
    }
}

// MARK: - iOS UI
#if os(iOS)
extension AddGoalView {
    var iosBody: some View {
        NavigationStack {
            Form {
                Section("Información del Objetivo") {
                    TextField("Título", text: $title)
                    TextField("Descripción (opcional)", text: $description)
                }
                
                Section("Meta") {
                    Stepper("Objetivo: \(targetCount) días", value: $targetCount, in: 1...365)
                    DatePicker("Fecha límite", selection: $targetDate, in: Date()..., displayedComponents: .date)
                }
                
                Section("Hábito Asociado") {
                    if habits.isEmpty {
                        Text("No hay hábitos disponibles")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Selecciona un hábito para vincular con este objetivo")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if selectedHabit == nil {
                                ForEach(habits) { habit in
                                    Button {
                                        selectedHabit = habit
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(habit.title)
                                                    .font(.body)
                                                    .foregroundColor(.primary)
                                                
                                                HStack {
                                                    ForEach(habit.scheduledDays, id: \.self) { day in
                                                        Text(dayName(for: day))
                                                            .font(.caption2)
                                                            .padding(.horizontal, 4)
                                                            .padding(.vertical, 1)
                                                            .background(Color.blue.opacity(0.2))
                                                            .cornerRadius(3)
                                                    }
                                                }
                                                
                                                if let priority = habit.priority {
                                                    Text("Prioridad: \(priority.displayName)")
                                                        .font(.caption)
                                                        .foregroundColor(priorityColor(for: priority))
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.vertical, 8)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    if habit.id != habits.last?.id {
                                        Divider()
                                    }
                                }
                                
                                Button("Ninguno") {
                                    selectedHabit = nil
                                }
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            } else {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(selectedHabit!.title)
                                            .font(.headline)
                                        
                                        HStack {
                                            ForEach(selectedHabit!.scheduledDays, id: \.self) { day in
                                                Text(dayName(for: day))
                                                    .font(.caption2)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Color.blue.opacity(0.1))
                                                    .cornerRadius(4)
                                            }
                                        }
                                        
                                        if let priority = selectedHabit!.priority {
                                            Text("Prioridad: \(priority.displayName)")
                                                .font(.caption)
                                                .foregroundColor(priorityColor(for: priority))
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Button("Cambiar") {
                                        selectedHabit = nil
                                    }
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Section("Hitos (opcional)") {
                    ForEach(milestones.indices, id: \.self) { index in
                        HStack {
                            TextField("Hito", text: $milestones[index].title)
                            Stepper("\(milestones[index].value)", value: $milestones[index].value, in: 1...targetCount)
                        }
                    }
                    .onDelete { indexSet in
                        milestones.remove(atOffsets: indexSet)
                    }
                    
                    Button("Agregar Hito") {
                        milestones.append(MilestoneInput(title: "", value: targetCount / 2))
                    }
                }
            }
            .navigationTitle("Nuevo Objetivo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveGoal()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
#endif

// MARK: - macOS UI
#if os(macOS)
extension AddGoalView {
    var macBody: some View {
        VStack(spacing: 20) {
            Form {
                Section("Información del Objetivo") {
                    TextField("Título", text: $title)
                    TextField("Descripción (opcional)", text: $description)
                }
                
                Section("Meta") {
                    Stepper("Objetivo: \(targetCount) días", value: $targetCount, in: 1...365)
                    DatePicker("Fecha límite", selection: $targetDate, in: Date()..., displayedComponents: .date)
                }
                
                Section("Hábito Asociado") {
                    Picker("Seleccionar hábito", selection: $selectedHabit) {
                        Text("Ninguno").tag(nil as Habit?)
                        ForEach(habits) { habit in
                            Text(habit.title).tag(habit as Habit?)
                        }
                    }
                }
                
                Section("Hitos (opcional)") {
                    ForEach(milestones.indices, id: \.self) { index in
                        HStack {
                            TextField("Hito", text: $milestones[index].title)
                            Stepper("\(milestones[index].value)", value: $milestones[index].value, in: 1...targetCount)
                        }
                    }
                    
                    Button("Agregar Hito") {
                        milestones.append(MilestoneInput(title: "", value: targetCount / 2))
                    }
                }
            }
            
            HStack(spacing: 12) {
                Button("Cancelar") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Guardar") {
                    saveGoal()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(title.isEmpty)
            }
            .padding()
        }
        .navigationTitle("Nuevo Objetivo")
        .frame(minWidth: 500, minHeight: 400)
        .padding()
    }
}
#endif

// MARK: - Common Functions
extension AddGoalView {
    
    private func saveGoal() {
        let goal = Goal(
            title: title,
            description: description,
            targetCount: targetCount,
            targetDate: targetDate,
            habitId: selectedHabit?.id
        )
        
        for milestoneInput in milestones where !milestoneInput.title.isEmpty {
            let milestone = Milestone(title: milestoneInput.title, targetValue: milestoneInput.value, goal: goal)
            modelContext.insert(milestone)
        }
        
        modelContext.insert(goal)
        try? modelContext.save()
        dismiss()
    }
    
    private func dayName(for weekday: Int) -> String {
        let dayNames = ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"]
        return dayNames[weekday - 1]
    }
    
    private func priorityColor(for priority: Priority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

struct MilestoneInput {
    var title: String
    var value: Int
}