import SwiftUI
import SwiftData

struct HabitListView: View {
    let storageProvider: StorageProvider
    @Query private var habits: [Habit]
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: HabitListViewModel
    @State private var currentDate = Date()
    @State private var showingNewHabitSheet = false
    private let calendar = Calendar.current
    private let weekdaySymbols = Calendar.current.shortStandaloneWeekdaySymbols
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        self._viewModel = StateObject(wrappedValue: HabitListViewModel(storageProvider: storageProvider))
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
extension HabitListView {
    var iosBody: some View {
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
                if filteredHabits.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Sin hábitos para hoy")
                            .font(.headline)
                        Text("No hay hábitos programados para este día")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredHabits) { habit in
                        HabitRowView(
                            habit: habit,
                            toggleCompletion: {
                                viewModel.toggleCompletion(habit: habit, for: currentDate)
                            },
                            viewModel: viewModel,
                            storageProvider: storageProvider,
                            date: currentDate
                        )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
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
                HabitDetailWrapper(
                    viewModel: viewModel,
                    habit: Habit(title: ""),
                    isNew: true
                )
            }
        }
        .onAppear {
            if habits.isEmpty {
                print("📝 Creando hábitos de muestra...")
                viewModel.createSampleHabits()
            }
        }
        // ⭐ Refrescar cuando cambian los hábitos
        .onChange(of: habits) { oldValue, newValue in
            print("🔄 Hábitos actualizados: \(newValue.count) hábitos")
        }
    }
}
#endif

// MARK: - macOS UI
#if os(macOS)
extension HabitListView {
    var macBody: some View {
        NavigationSplitView {
            VStack(spacing: 16) {
                // Selector de días
                HStack(spacing: 8) {
                    ForEach(1...7, id: \.self) { index in
                        let dayName = weekdaySymbols[index - 1]
                        let isSelected = calendar.component(.weekday, from: currentDate) == index
                        
                        Button(action: {
                            currentDate = dateForWeekday(index)
                        }) {
                            VStack(spacing: 4) {
                                Text(dayName.prefix(2))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text(shortDate(for: index))
                                    .font(.caption2)
                            }
                            .foregroundColor(isSelected ? .white : .primary)
                            .frame(width: 50, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
                
                Divider()
                
                // Lista de hábitos
                if filteredHabits.isEmpty {
                    VStack {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Sin hábitos para hoy")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredHabits) { habit in
                        HabitRowView(
                            habit: habit,
                            toggleCompletion: {
                                viewModel.toggleCompletion(habit: habit, for: currentDate)
                            },
                            viewModel: viewModel,
                            storageProvider: storageProvider,
                            date: currentDate
                        )
                    }
                }
            }
            .navigationTitle("Hábitos")
            .toolbar {
                ToolbarItem {
                    Button {
                        showingNewHabitSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        } detail: {
            VStack {
                Text("Tareas para \(dayName(for: currentDate))")
                    .font(.title2)
                Text(currentDate, format: .dateTime.day().month().year())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if filteredHabits.isEmpty {
                    ContentUnavailableView(
                        "Sin hábitos",
                        systemImage: "checkmark.circle",
                        description: Text("No hay hábitos programados para este día")
                    )
                } else {
                    Text("\(filteredHabits.count) hábito(s) programado(s)")
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .sheet(isPresented: $showingNewHabitSheet) {
            HabitDetailWrapper(
                viewModel: viewModel,
                habit: Habit(title: ""),
                isNew: true
            )
        }
        .onAppear {
            if habits.isEmpty {
                print("📝 Creando hábitos de muestra...")
                viewModel.createSampleHabits()
            }
        }
        // ⭐ Refrescar cuando cambian los hábitos
        .onChange(of: habits) { oldValue, newValue in
            print("🔄 Hábitos actualizados: \(newValue.count) hábitos")
        }
    }
}
#endif

// MARK: - Helpers
extension HabitListView {
    
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
}
