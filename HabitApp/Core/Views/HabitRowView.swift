import SwiftUI
import SwiftData

struct HabitRowView: View {
    let habit: Habit
    let toggleCompletion: () -> Void
    let viewModel: HabitListViewModel
    let storageProvider: StorageProvider
    var date: Date = Date()
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        HStack(spacing: 12) {
            // 🔹 Botón para marcar completado (Gatillo de la racha)
            Button(action: {
                // Ejecutamos la acción y la racha se actualizará vía Plugin
                toggleCompletion()
                // Feedback háptico opcional para mejorar la sensación de "responsividad"
                #if os(iOS)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                #endif
            }) {
                Image(systemName: habit.isCompletedForDate(date) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(habit.isCompletedForDate(date) ? .green : .gray)
                    .font(.title2) // Un poco más grande para facilitar el toque
            }
            .buttonStyle(.plain)
            
            // 🔹 Información del hábito
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .center, spacing: 8) {
                    Text(habit.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .strikethrough(habit.isCompletedForDate(date))
                        .foregroundColor(habit.isCompletedForDate(date) ? .gray : .primary)
                        .lineLimit(1)
                    
                    // 🔥 INTEGRACIÓN DE RACHAS
                    // Al estar dentro de un HStack con el título, la llama "sigue" al texto
                    if AppConfig.enableStreaks {
                        StreakBadgeView(habitId: habit.id)
                            .animation(.spring(), value: habit.doneDatesString)
                    }
                }
                
                // Detalles secundarios
                Group {
                    if AppConfig.showDueDates, let dueDate = habit.dueDate {
                        Text("Vence: \(dueDate.formatted(date: .abbreviated, time: .shortened))")
                    }
                    
                    if AppConfig.showPriorities, let priority = habit.priority {
                        Text("Prioridad: \(priority.rawValue.capitalized)")
                            .foregroundColor(priorityColor(for: priority))
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 🔹 Acciones (Notas, Editar, Eliminar)
            HStack(spacing: 15) {
                NavigationLink {
                    HabitNotesView(habit: habit, currentDate: date, storageProvider: storageProvider)
                } label: {
                    Image(systemName: "note.text")
                        .foregroundColor(.blue.opacity(0.8))
                }
                .buttonStyle(.plain)
                
                Button {
                    showingEditSheet = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundColor(.orange.opacity(0.8))
                }
                .buttonStyle(.plain)
                
                Button {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
            .font(.system(size: 16))
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingEditSheet) {
            HabitDetailWrapper(viewModel: viewModel, habit: habit, isNew: false)
        }
        .alert("¿Eliminar hábito?", isPresented: $showingDeleteAlert) {
            Button("Eliminar", role: .destructive) {
                deleteHabit()
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Esta acción eliminará el hábito y su historial de rachas.")
        }
    }
    
    private func deleteHabit() {
        // Al borrar el hábito, SwiftData se encargará de limpiar el context
        modelContext.delete(habit)
        
        do {
            try modelContext.save()
        } catch {
            print("❌ Error al eliminar: \(error)")
        }
    }
    
    private func priorityColor(for priority: Priority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .red
        }
    }
}
