import SwiftUI
import SwiftData

struct HabitDetailWrapper: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let viewModel: HabitListViewModel
    let isNew: Bool
    
    //  Estados locales para evitar binding directo con @State var habit
    @State private var title: String
    @State private var selectedDays: [Int]
    @State private var priority: Priority
    @State private var habitToEdit: Habit?
    
    init(viewModel: HabitListViewModel, habit: Habit, isNew: Bool = true) {
        self.viewModel = viewModel
        self.isNew = isNew
        self.habitToEdit = isNew ? nil : habit
        
        // Inicializar estados locales
        _title = State(initialValue: habit.title)
        _selectedDays = State(initialValue: habit.scheduledDays)
        _priority = State(initialValue: habit.priority ?? .medium)
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
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.05),
                        Color.purple.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        //  Título
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "text.cursor")
                                    .foregroundColor(.blue)
                                Text("Título")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            TextField("Ej: Hacer ejercicio", text: $title)
                                .textFieldStyle(.roundedBorder)
                                .font(.body)
                        }
                        .padding(16)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        
                        //  Días de la semana
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.orange)
                                Text("Días de la semana")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            WeekdaySelector(selectedDays: $selectedDays)
                                .padding(.vertical, 4)
                        }
                        .padding(16)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        
                        //  Prioridad
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "flag.fill")
                                    .foregroundColor(.red)
                                Text("Prioridad")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            Picker("Prioridad", selection: $priority) {
                                ForEach(Priority.allCases, id: \.self) { priority in
                                    Text(priority.displayName).tag(priority)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(16)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        
                        //  Botones
                        VStack(spacing: 12) {
                            Button(action: saveHabit) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text(isNew ? "Crear hábito" : "Guardar cambios")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                            .disabled(title.isEmpty || selectedDays.isEmpty)
                            
                            if !isNew {
                                Button(action: deleteHabit) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "trash.fill")
                                        Text("Eliminar hábito")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: Color.red.opacity(0.3), radius: 4, x: 0, y: 2)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(16)
                }
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
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.08),
                    Color.purple.opacity(0.08)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isNew ? "Nuevo hábito" : "Editar hábito")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Configura los detalles de tu hábito")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 16) {
                    // Título
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "text.cursor")
                                .foregroundColor(.blue)
                            Text("Título del hábito")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        TextField("Ej: Hacer ejercicio", text: $title)
                            .textFieldStyle(.roundedBorder)
                            .font(.body)
                    }
                    .padding(12)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(10)
                    
                    // Días de la semana
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .foregroundColor(.orange)
                            Text("Días de la semana")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        WeekdaySelector(selectedDays: $selectedDays)
                            .padding(.vertical, 4)
                    }
                    .padding(12)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(10)
                    
                    // Prioridad
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "flag.fill")
                                .foregroundColor(.red)
                            Text("Prioridad")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        Picker("Prioridad", selection: $priority) {
                            ForEach(Priority.allCases, id: \.self) { priority in
                                Text(priority.displayName).tag(priority)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(12)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Botones
                HStack(spacing: 12) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                    
                    Spacer()
                    
                    if !isNew {
                        Button("Eliminar") {
                            deleteHabit()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .controlSize(.large)
                    }
                    
                    Button(isNew ? "Crear" : "Guardar") {
                        saveHabit()
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
                    .controlSize(.large)
                    .disabled(title.isEmpty || selectedDays.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(minWidth: 450, minHeight: 380)
    }
}
#endif

// MARK: - Helpers
extension HabitDetailWrapper {
    private func saveHabit() {
        if isNew {
            //  Crear nuevo hábito
            viewModel.addHabit(
                title: title,
                dueDate: nil,
                priority: priority,
                reminderDate: nil,
                scheduledDays: selectedDays
            )
        } else if let habitToEdit = habitToEdit {
            //  Actualizar hábito existente
            habitToEdit.title = title
            habitToEdit.scheduledDaysString = selectedDays.map { String($0) }.joined(separator: ",")
            habitToEdit.priority = priority
            viewModel.updateHabit(habitToEdit)
        }
        
        dismiss()
    }
    
    private func deleteHabit() {
        if let habitToEdit = habitToEdit {
            viewModel.deleteHabit(habitToEdit)
            dismiss()
        }
    }
}
