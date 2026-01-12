import SwiftUI

struct PerHabitStatsView: View {
    let habitStats: [HabitStats]
    let isLoading: Bool
    @State private var expandedHabitId: UUID?
    
    var body: some View {
        if isLoading {
            ProgressView("Cargando...")
                .padding()
        } else if habitStats.isEmpty {
            ContentUnavailableView(
                "Sin hábitos",
                systemImage: "list.bullet",
                description: Text("No hay hábitos con estadísticas")
            )
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(habitStats) { habit in
                        HabitStatRow(
                            habit: habit,
                            isExpanded: expandedHabitId == habit.id
                        ) {
                            withAnimation {
                                expandedHabitId = expandedHabitId == habit.id ? nil : habit.id
                            }
                        }
                    }
                }
                #if os(macOS)
                .frame(maxWidth: 700, alignment: .topLeading)
                #endif
                .padding()
                #if os(macOS)
                .padding(.leading, 20)
                #endif
            }
        }
    }
}

struct HabitStatRow: View {
    let habit: HabitStats
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: onTap) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(habit.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            Text("\(habit.totalCompleted)/\(habit.totalExpected)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(Int(habit.overallRate * 100))%")
                                .font(.caption.bold())
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                #if os(iOS)
                .background(Color(.systemGray6))
                #endif
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            
            // Detalle expandido
            if isExpanded {
                VStack(spacing: 12) {
                    Divider()
                        .padding(.horizontal)
                    
                    if !habit.periods.isEmpty {
                        // Filtrar solo días relevantes: programados o completados
                        let relevantPeriods = habit.periods.filter { period in
                            period.expectedCount > 0 || period.completedCount > 0
                        }
                        
                        if !relevantPeriods.isEmpty {
                            CompactHabitStatsView(periods: relevantPeriods)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
        #if os(iOS)
        .background(Color.white)
        #endif
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
