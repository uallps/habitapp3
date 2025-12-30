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
            habit: selectedHabit
        )
        
        for milestoneInput in milestones where !milestoneInput.title.isEmpty {
            let milestone = Milestone(title: milestoneInput.title, targetValue: milestoneInput.value, goal: goal)
            modelContext.insert(milestone)
        }
        
        modelContext.insert(goal)
        try? modelContext.save()
        dismiss()
    }
}

struct MilestoneInput {
    var title: String
    var value: Int
}