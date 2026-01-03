import SwiftUI
import SwiftData

struct StatisticsView: View {
    @EnvironmentObject private var appConfig: AppConfig
    @StateObject private var viewModel: StatisticsViewModel
    @State private var selectedTab = 0
    @State private var statisticsPlugin: StatisticsPlugin?
    
    init() {
        // La inicialización del ViewModel se hace con el storageProvider compartido
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(storageProvider: AppConfig().storageProvider))
    }
    
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
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Estadísticas")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .onAppear {
                // Cargar estadísticas inicialmente
                viewModel.loadStatistics()
                
                // Registrar plugin para actualizaciones automáticas
                if statisticsPlugin == nil {
                    let plugin = StatisticsPlugin(viewModel: viewModel)
                    statisticsPlugin = plugin
                    PluginRegistry.shared.register(plugin: plugin)
                }
            }
        }
    }
}
