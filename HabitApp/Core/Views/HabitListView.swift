import SwiftUI

struct HabitListView: View {
    @ObservedObject var viewModel: HabitListViewModel
    @State private var currentDate = Date()
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
                    NavigationLink(value: habit) {
                        HabitRowView(
                            habit: habit,
                            toggleCompletion: {
                                viewModel.toggleCompletion(habit: habit)
                            }
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Hábitos")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    NavigationLink {
                        HabitDetailWrapper(
                            viewModel: viewModel,
                            habit: Habit(title: "", doneDays: [])
                        )
                    } label: {
                        Label("Añadir", systemImage: "plus")
                    }
                }
            }

            .listStyle(.automatic)
        }
    }
    
    // MARK: - Helpers
    
    private var filteredHabits: [Habit] {
        let weekday = calendar.component(.weekday, from: currentDate)
        return viewModel.habits.filter { $0.scheduledDays.contains(weekday) }
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
}
