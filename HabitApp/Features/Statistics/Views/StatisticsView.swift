import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = StatisticsViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Selector de rango
                Picker("Rango", selection: $viewModel.selectedRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Selector de vista (solo en rango semanal)
                if viewModel.selectedRange == .week {
                    Picker("Vista", selection: $selectedTab) {
                        Text("General").tag(0)
                        Text("Por Hábito").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                }
                
                // Contenido
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
                    #if os(iOS)
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    #endif
                }
            }
            .navigationTitle("Estadísticas")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .onAppear {
                viewModel.configure(with: modelContext)
            }
        }
    }
}
