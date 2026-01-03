import SwiftUI
import SwiftData
struct HabitRowView: View {

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appConfig: AppConfig
    
    let habit: Habit
    let toggleCompletion: () -> Void
    var date: Date = Date()
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack {
            // 🔹 Botón para marcar completado
            Button(action: toggleCompletion) {
                Image(systemName: habit.isCompletedForDate(date) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(habit.isCompletedForDate(date) ? .green : .gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            
            // 🔹 Información del hábito
            VStack(alignment: .leading) {
                Text(habit.title)
                    .strikethrough(habit.isCompletedForDate(date))
                    .foregroundColor(habit.isCompletedForDate(date) ? .gray : .primary)
                
                if AppConfig.showDueDates, let dueDate = habit.dueDate {
                    Text("Vence: \(dueDate.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if AppConfig.showPriorities, let priority = habit.priority {
                    Text("Prioridad: \(priority.localized.togglingFirstLetterCase)")
                        .font(.caption)
                        .foregroundColor(priorityColor(for: priority))
                }
            }
            
            Spacer()
            
            // 🔹 Navegación a notas
            NavigationLink {
                HabitNotesView(habit: habit, modelContext: modelContext)
            } label: {
                Image(systemName: "note.text")
                    .foregroundColor(.blue)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            
            // 🔹 Botón para editar
            Button {
                showingEditSheet = true
            } label: {
                Image(systemName: "pencil")
                    .foregroundColor(.orange)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .padding(.leading, 4)
            
            // 🔹 Botón para eliminar
            Button {
                showingDeleteAlert = true
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .padding(.leading, 2)
        }
        .sheet(isPresented: $showingEditSheet) {
            HabitDetailWrapper(
                habitListVM: HabitListViewModel(
                    storageProvider: appConfig.storageProvider
                ),
                isNew: false,
                habit: habit,
                storageProvider: appConfig.storageProvider
            )
        }
        .alert("¿Eliminar hábito?", isPresented: $showingDeleteAlert) {
            Button("Eliminar", role: .destructive) {
                deleteHabit()
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Esta acción no se puede deshacer")
        }
    }
    
    private func deleteHabit() {
        modelContext.delete(habit)
        try? modelContext.save()
    }
    
    private func priorityColor(for priority: Priority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .red
        case .mixed: return .pink
        }
    }
}
