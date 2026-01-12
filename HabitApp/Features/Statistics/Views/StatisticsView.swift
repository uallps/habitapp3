import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Query private var habits: [Habit]
    @StateObject private var viewModel = StatisticsViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Selector de rango (solo en iOS)
                #if os(iOS)
                Picker("Rango", selection: $viewModel.selectedRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                #endif

                // Selector de vista (solo en rango semanal en iOS)
                #if os(iOS)
                if viewModel.selectedRange == .week {
                    Picker("Vista", selection: $selectedTab) {
                        Text("General").tag(0)
                        Text("Por Hábito").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                }
                #endif

                // Contenido
                #if os(iOS)
                if viewModel.selectedRange == .day {
                    OverviewStatsView(
                        stats: viewModel.generalStats,
                        isLoading: viewModel.isLoading
                    )
                } else {
                    TabView(selection: $selectedTab) {
                        OverviewStatsView(
                            stats: viewModel.generalStats,
                            isLoading: viewModel.isLoading
                        )
                        .tag(0)
                        
                        PerHabitStatsView(
                            habitStats: viewModel.habitStats,
                            isLoading: viewModel.isLoading
                        )
                        .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                #else
                // macOS: Dashboard completo con todas las vistas
                ScrollView {
                    VStack(alignment: .leading, spacing: 40) {
                        // 1. Vista Diaria
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Hoy")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            // Necesitamos calcular stats para hoy
                            if let dayStats = viewModel.dayStats {
                                OverviewStatsView(
                                    stats: dayStats,
                                    isLoading: viewModel.isLoading
                                )
                            }
                        }
                        
                        Divider()
                        
                        // 2. Vista Semanal General
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Semana - Resumen General")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            OverviewStatsView(
                                stats: viewModel.generalStats,
                                isLoading: viewModel.isLoading
                            )
                        }
                        
                        Divider()
                        
                        // 3. Vista Semanal Por Hábito
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Semana - Por Hábito")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            PerHabitStatsView(
                                habitStats: viewModel.habitStats,
                                isLoading: viewModel.isLoading
                            )
                        }
                    }
                    .padding()
                }
                #endif
            }
            .navigationTitle("Estadísticas")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .onAppear {
                // Push current habits from @Query to the view model
                viewModel.loadStatistics(from: habits)
            }
            .onChange(of: habits) {
                viewModel.loadStatistics(from: habits)
            }
            .onChange(of: viewModel.selectedRange) {
                viewModel.loadStatistics(from: habits)
            }
        }
    }
}
