import SwiftUI
import SwiftData

struct HabitDetailWrapper: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: HabitListViewModel
    @State var habit: Habit
    private let isNew: Bool
    
    init(viewModel: HabitListViewModel, habit: Habit, isNew: Bool = true) {
        self.viewModel = viewModel
        self._habit = State(initialValue: habit)
        self.isNew = isNew
    }

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
extension HabitDetailWrapper {
    var iosBody: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 🔹 Título
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Título")
                            .font(.headline)
                            .foregroundColor(.primary)
                        TextField("Nombre del hábito", text: $habit.title)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // 🔹 Días de la semana
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Días de la semana")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        WeekdaySelector(selectedDays: $habit.scheduledDays)
                    }
                    
                    // 🔹 Prioridad
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Prioridad")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Picker("Prioridad", selection: Binding(
                            get: { habit.priority ?? .medium },
                            set: { habit.priority = $0 }
                        )) {
                            ForEach(Priority.allCases, id: \.self) { priority in
                                Text(priority.rawValue.capitalized).tag(priority)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    
                    // 🔹 Botones
                    VStack(spacing: 12) {
                        Button(action: {
                            viewModel.addHabit(
                                title: habit.title,
                                dueDate: habit.dueDate,
                                priority: habit.priority,
                                reminderDate: habit.reminderDate,
                                scheduledDays: habit.scheduledDays,
                                context: modelContext
                            )
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "checkmark")
                                Text(isNew ? "Crear hábito" : "Guardar cambios")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .disabled(habit.title.isEmpty)
                        
                        if !isNew {
                            Button(action: {
                                viewModel.deleteHabit(habit, context: modelContext)
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Eliminar hábito")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(isNew ? "Nuevo hábito" : "Editar hábito")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
#endif

// MARK: - macOS UI
#if os(macOS)
extension HabitDetailWrapper {
    var macBody: some View {
        VStack(spacing: 20) {
            Form {
                Section("Información del hábito") {
                    TextField("Nombre del hábito", text: $habit.title)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Días de la semana")
                            .font(.headline)
                        WeekdaySelector(selectedDays: $habit.scheduledDays)
                    }
                    
                    Picker("Prioridad", selection: Binding(
                        get: { habit.priority ?? .medium },
                        set: { habit.priority = $0 }
                    )) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue.capitalized).tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            
            HStack(spacing: 12) {
                Button("Cancelar") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                if !isNew {
                    Button("Eliminar") {
                        viewModel.deleteHabit(habit, context: modelContext)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlProminence(.increased)
                    .tint(.red)
                }
                
                Button(isNew ? "Crear" : "Guardar") {
                    if isNew {
                        viewModel.addHabit(
                            title: habit.title,
                            dueDate: habit.dueDate,
                            priority: habit.priority,
                            reminderDate: habit.reminderDate,
                            scheduledDays: habit.scheduledDays,
                            context: modelContext
                        )
                    } else {
                        viewModel.updateHabit(habit, context: modelContext)
                    }
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(habit.title.isEmpty)
            }
            .padding()
        }
        .navigationTitle(isNew ? "Nuevo hábito" : "Editar hábito")
        .frame(minWidth: 400, minHeight: 300)
        .padding()
    }
}
#endif
