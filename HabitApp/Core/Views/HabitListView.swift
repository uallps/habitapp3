import SwiftUI
import SwiftData

struct HabitListView: View {
    let storageProvider: StorageProvider
    let wildcardService = WildcardHabitService()
    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: HabitListViewModel
    @State private var currentDate = Date()
    @State private var showingNewHabitSheet = false
    private let calendar = Calendar.current
    private let weekdaySymbols = Calendar.current.shortStandaloneWeekdaySymbols
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        self._viewModel = StateObject(wrappedValue: HabitListViewModel(
            storageProvider: storageProvider,
            wildcardProvider: wildcardService
        ))
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
            VStack(spacing: 0) {
                //  Encabezado compacto
                VStack(spacing: 8) {
                    HStack {
                        Text(monthYearString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if !filteredHabits.isEmpty {
                            Text("\(filteredHabits.count) tarea\(filteredHabits.count == 1 ? "" : "s")")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.blue)
                                .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Selector de días - MÁS COMPACTO
                    HStack(spacing: 6) {
                        ForEach(1...7, id: \.self) { index in
                            let dayName = weekdaySymbols[index - 1]
                            let isSelected = calendar.component(.weekday, from: currentDate) == index
                            let isToday = calendar.component(.weekday, from: Date()) == index
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    currentDate = dateForWeekday(index)
                                }
                            }) {
                                VStack(spacing: 2) {
                                    Text(String(dayName.prefix(1)))
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(isSelected ? .white : (isToday ? .blue : .secondary))
                                    
                                    Text(shortDate(for: index))
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(isSelected ? .white : .primary)
                                    
                                    if hasHabitsForDay(index) {
                                        Circle()
                                            .fill(isSelected ? Color.white : Color.blue)
                                            .frame(width: 3, height: 3)
                                    } else {
                                        Circle()
                                            .fill(Color.clear)
                                            .frame(width: 3, height: 3)
                                    }
                                }
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(isSelected ? Color.blue : (isToday ? Color.blue.opacity(0.1) : Color.gray.opacity(0.08)))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(isToday && !isSelected ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
                .background(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                Divider()
                
                //  Día actual - MÁS COMPACTO
                HStack {
                    Text(dayName(for: currentDate))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("·")
                        .foregroundColor(.secondary)
                    
                    Text(currentDate, format: .dateTime.day().month())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                Divider()
                
                //  Lista de hábitos (SIEMPRE dentro de List)
                List {
                    if filteredHabits.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: habits.isEmpty ? "plus.circle" : "checkmark.circle")
                                .font(.system(size: 48))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text(habits.isEmpty ? "Sin hábitos creados" : "Sin hábitos para hoy")
                                .font(.headline)
                            
                            if habits.isEmpty {
                                Text("Crea hábitos de ejemplo para empezar")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                Button("Crear hábitos de muestra") {
                                    viewModel.createSampleHabits()
                                }
                                .buttonStyle(.borderedProminent)
                                .padding(.top, 8)
                            } else {
                                Text("No hay hábitos programados para hoy")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(filteredHabits, id: \.id) { habit in
                            HabitRowView(
                                habit: habit,
                                toggleCompletion: {
                                    withAnimation {
                                        viewModel.toggleCompletion(habit: habit, for: currentDate)
                                    }
                                },
                                viewModel: viewModel,
                                storageProvider: storageProvider,
                                date: currentDate
                            )
                            .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                            .listRowSeparator(.hidden)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Hábitos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            withAnimation {
                                viewModel.unlockWildcardHabit()
                            }
                        } label: {
                            Image(systemName: "dice.fill")
                                .font(.title3)
                                .foregroundColor(.purple)
                        }
                        
                        Button {
                            showingNewHabitSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
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
            
            //
        }
    }
}
#endif

// MARK: - macOS UI
#if os(macOS)
extension HabitListView {
    var macBody: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            VStack(spacing: 0) {
                // Header compacto
                HStack {
                    Text(monthYearString)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    if !filteredHabits.isEmpty {
                        Text("\(filteredHabits.count)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.blue)
                            .cornerRadius(6)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.windowBackgroundColor))
                
                Divider()
                
                // Selector de días compacto
                HStack(spacing: 4) {
                    ForEach(1...7, id: \.self) { index in
                        let dayName = weekdaySymbols[index - 1]
                        let isSelected = calendar.component(.weekday, from: currentDate) == index
                        let isToday = calendar.component(.weekday, from: Date()) == index
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                currentDate = dateForWeekday(index)
                            }
                        }) {
                            VStack(spacing: 2) {
                                Text(String(dayName.prefix(1)))
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(isSelected ? .white : (isToday ? .blue : .secondary))
                                
                                Text(shortDate(for: index))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(isSelected ? .white : .primary)
                                
                                if hasHabitsForDay(index) {
                                    Circle()
                                        .fill(isSelected ? Color.white : Color.blue)
                                        .frame(width: 3, height: 3)
                                } else {
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: 3, height: 3)
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(isSelected ? Color.blue : (isToday ? Color.blue.opacity(0.1) : Color.gray.opacity(0.08)))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(isToday && !isSelected ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(Color(.windowBackgroundColor))
                
                Divider()
                
                // Lista de hábitos
                List {
                    if filteredHabits.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: habits.isEmpty ? "plus.circle" : "checkmark.circle")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            
                            Text(habits.isEmpty ? "Sin hábitos creados" : "Sin hábitos para hoy")
                                .font(.headline)
                            
                            if habits.isEmpty {
                                Button("Crear hábito de muestra") {
                                    viewModel.createSampleHabits()
                                }
                                .buttonStyle(.borderedProminent)
                            } else {
                                Text("No hay hábitos programados")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(filteredHabits, id: \.id) { habit in
                            HabitRowView(
                                habit: habit,
                                toggleCompletion: {
                                    withAnimation {
                                        viewModel.toggleCompletion(habit: habit, for: currentDate)
                                    }
                                },
                                viewModel: viewModel,
                                storageProvider: storageProvider,
                                date: currentDate
                            )
                            .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        }
                    }
                }
                .listStyle(.sidebar)
            }
            .navigationTitle("Hábitos")
            .navigationSplitViewColumnWidth(min: 280, ideal: 350, max: 450)
            .toolbar {
                ToolbarItem {
                    HStack {
                         Button {
                            withAnimation {
                                viewModel.unlockWildcardHabit()
                            }
                        } label: {
                            Image(systemName: "dice.fill")
                                .foregroundColor(.purple)
                        }
                        
                        Button {
                            showingNewHabitSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        } detail: {
            VStack(spacing: 16) {
                Text("Tareas para \(dayName(for: currentDate))")
                    .font(.title2)
                Text(currentDate, format: .dateTime.day().month().year())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if filteredHabits.isEmpty {
                    ContentUnavailableView(
                        habits.isEmpty ? "Sin hábitos" : "Sin hábitos para hoy",
                        systemImage: habits.isEmpty ? "plus.circle" : "checkmark.circle",
                        description: Text(habits.isEmpty ? "Crea tu primer hábito" : "No hay hábitos programados")
                    )
                } else {
                    Text("\(filteredHabits.count) hábito(s) programado(s)")
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationSplitViewColumnWidth(min: 300, ideal: 400, max: 500)
        }
        .sheet(isPresented: $showingNewHabitSheet) {
            HabitDetailWrapper(
                viewModel: viewModel,
                habit: Habit(title: ""),
                isNew: true
            )
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
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: currentDate).capitalized
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
    
    private func hasHabitsForDay(_ weekday: Int) -> Bool {
        return habits.contains { $0.scheduledDays.contains(weekday) }
    }
}
