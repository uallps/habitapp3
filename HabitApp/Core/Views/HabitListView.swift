import SwiftUI
import SwiftData

struct HabitListView: View {
    @ObservedObject var viewModel: HabitListViewModel
    @Query private var habits: [Habit]
    @Environment(\.modelContext) private var modelContext
    @State private var currentDate = Date()
    @State private var showingNewHabitSheet = false
    private let calendar = Calendar.current
    private let weekdaySymbols = Calendar.current.shortStandaloneWeekdaySymbols

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                
                // 🔹 Encabezado semanal
                HStack(spacing: 10) {
                    ForEach(1...7, id: \.self) { index in
                        let dayName = weekdaySymbols[index - 1]
                        let isSelected = calendar.component(.weekday, from: currentDate) == index
                        
                        Button(action: {
                            currentDate = dateForWeekday(index)
                        }) {
                            VStack {
                                Text(dayName.prefix(2))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(isSelected ? .white : .primary)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                                    )
                                Text(shortDate(for: index))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 8)
                
                Divider()
                
                // 🔹 Día actual seleccionado
                VStack(spacing: 2) {
                    Text("Tareas para \(dayName(for: currentDate))")
                        .font(.headline)
                    Text(currentDate, format: .dateTime.day().month().year())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 6)
                
                // 🔹 Lista de hábitos filtrados
                List(filteredHabits) { habit in
                    HabitRowView(
                        habit: habit,
                        toggleCompletion: {
                            viewModel.toggleCompletion(habit: habit, for: currentDate)
                        },
                        date: currentDate
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Hábitos")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showingNewHabitSheet = true
                    } label: {
                        Label("Añadir", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewHabitSheet) {
                // Abrimos HabitDetailWrapper para crear un nuevo hábito
                HabitDetailWrapper(
                    habitListVM: HabitListViewModel(),
                    isNew: true,
                    habit: Habit(title: "")
                )
            }
        }
        .onAppear {
            if habits.isEmpty {
                createSampleHabits()
            }
        }
    }
    
    // MARK: - Helpers
    
    private var filteredHabits: [Habit] {
        let weekday = calendar.component(.weekday, from: currentDate)
        return habits.filter { $0.scheduledDays.contains(weekday) }
    }
    
    private func dayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date).capitalized
    }
    
    private func shortDate(for weekday: Int) -> String {
        let today = calendar.startOfDay(for: Date())
        let todayWeekday = calendar.component(.weekday, from: today)
        let diff = weekday - todayWeekday
        if let date = calendar.date(byAdding: .day, value: diff, to: today) {
            let formatter = DateFormatter()
            formatter.dateFormat = "d"
            return formatter.string(from: date)
        }
        return ""
    }
    
    private func dateForWeekday(_ weekday: Int) -> Date {
        let today = calendar.startOfDay(for: Date())
        let todayWeekday = calendar.component(.weekday, from: today)
        let diff = weekday - todayWeekday
        return calendar.date(byAdding: .day, value: diff, to: today) ?? today
    }
    
    private func createSampleHabits() {
        let sampleHabits = [
            Habit(title: "Hacer ejercicio", priority: .high, scheduledDays: [2, 4, 6]),
            Habit(title: "Leer 30 minutos", priority: .medium, scheduledDays: [1, 2, 3, 4, 5, 6, 7]),
            Habit(title: "Meditar", priority: .low, scheduledDays: [1, 7])
        ]
        
        for habit in sampleHabits {
            modelContext.insert(habit)
        }
        
        try? modelContext.save()
    }
}
