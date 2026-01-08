import SwiftUI
import SwiftData

struct AddictionistView: View {
    @Query(sort: \Addiction.createdAt) private var addictions: [Addiction]
    @StateObject private var addictionListVM: AddictionListViewModel
    @State private var currentDate = Date()
    @State private var showingNewAddictionSheet = false
    private let calendar = Calendar.current
    private let weekdaySymbols = Calendar.current.shortStandaloneWeekdaySymbols
    
    init(storageProvider: StorageProvider) {
        self._addictionListVM = StateObject(wrappedValue: HabitListaddictionListVM(storageProvider: storageProvider))
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
                        
                        if !filteredAddictions.isEmpty {
                            Text("\(filteredAddictions.count) tarea\(filteredAddictions.count == 1 ? "" : "s")")
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
                
                //  Lista de adicciones (SIEMPRE dentro de List)
                List {
                    if filteredAddictions.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: addictions.isEmpty ? "plus.circle" : "checkmark.circle")
                                .font(.system(size: 48))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text(addictions.isEmpty ? "Sin adicciones creadas" : "Sin adicciones para hoy")
                                .font(.headline)
                            
                            if addictions.isEmpty {
                                Text("Crea adiciones de ejemplo para empezar")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                Button("Crear adicciones de muestra") {
                                    addictionListVM.createSampleHabits()
                                }
                                .buttonStyle(.borderedProminent)
                                .padding(.top, 8)
                            } else {
                                Text("No hay adicciones programadas para hoy")
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
                        ForEach(filteredAddictions, id: \.id) { addiction in
                            AddictionRowView(
                                addiction: addiction
                            )
                            .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                            .listRowSeparator(.hidden)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("adicciones")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewAddictionSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingNewAddictionSheet) {
                AddictionDetailWrapperView(
                    addictionListVM: addictionListVM,
                    addiction: Addiction(title: ""),
                    isNew: true
                )
            }
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
                    
                    if !filteredAddictions.isEmpty {
                        Text("\(filteredAddictions.count)")
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
                
                // Lista de adicciones
                List {
                    if filteredAddictions.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: addictions.isEmpty ? "plus.circle" : "checkmark.circle")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            
                            Text(addictions.isEmpty ? "Sin adicciones creadas" : "Sin adicciones para hoy")
                                .font(.headline)
                            
                            if addictions.isEmpty {
                                Button("Crear addición de muestra") {
                                    addictionListVM.createSampleHabits()
                                }
                                .buttonStyle(.borderedProminent)
                            } else {
                                Text("No hay adicciones programados")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(filteredAddictions, id: \.id) { addiction in
                            AddictionRowView(
                                addiction: addiction
                            )
                            .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                            .listRowSeparator(.hidden)

                        }
                    }
                }
                .listStyle(.sidebar)
            }
            .navigationTitle("adicciones")
            .navigationSplitViewColumnWidth(min: 280, ideal: 350, max: 450)
            .toolbar {
                ToolbarItem {
                    Button {
                        showingNewAddictionSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
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
                
                if filteredAddictions.isEmpty {
                    ContentUnavailableView(
                        addictions.isEmpty ? "Sin adicciones" : "Sin adicciones para hoy",
                        systemImage: addictions.isEmpty ? "plus.circle" : "checkmark.circle",
                        description: Text(addictions.isEmpty ? "Crea tu primera addición" : "No hay adicciones programadas")
                    )
                } else {
                    Text("\(filteredAddictions.count) addición(s) programado(s)")
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationSplitViewColumnWidth(min: 300, ideal: 400, max: 500)
        }
        .sheet(isPresented: $showingNewAddictionSheet) {
            AddictionDetailWrapperView(
                addictionListVM: addictionListVM,
                addiction: Addiction(title: ""),
                isNew: true
            )
        }
    }
}
#endif

// MARK: - Helpers
extension HabitListView {
    
    private var filteredAddictions: [Addiction] {
        let weekday = calendar.component(.weekday, from: currentDate)
        return addictions.filter { $0.scheduledDays.contains(weekday) }
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
        return addictions.contains { $0.scheduledDays.contains(weekday) }
    }
}