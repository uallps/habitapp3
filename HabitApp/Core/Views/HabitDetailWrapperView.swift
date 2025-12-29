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
        VStack(spacing: 20) {
            // 🔹 Título
            TextField("Título del hábito", text: $habit.title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // 🔹 Días de la semana
            Text("Selecciona los días de la semana")
                .font(.headline)
            
            WeekdaySelector(selectedDays: $habit.scheduledDays)
                .padding(.horizontal)
            
            // 🔹 Prioridad
            Text("Prioridad")
                .font(.headline)
                .padding(.top)
            
            Picker("Prioridad", selection: Binding(
                get: { habit.priority ?? .medium },
                set: { habit.priority = $0 }
            )) {
                ForEach(Priority.allCases, id: \.self) { priority in
                    Text(priority.rawValue.capitalized).tag(priority)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            Spacer()
            
            // 🔹 Botón Guardar
            Button(action: saveHabit) {
                Text("Guardar hábito")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding(.horizontal)
            }
            .background(Color.blue)
            .cornerRadius(10)
            
            // 🔹 Botón Eliminar (solo si no es nuevo)
       
        }
        .navigationTitle(isNew ? "Nuevo hábito" : "Editar hábito")
        .padding()
    }
    
    // MARK: - Funciones
    private func saveHabit() {
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
    
    private func deleteHabit() {
        viewModel.deleteHabit(habit, context: modelContext)
        dismiss()
    }
}
