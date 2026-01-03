import SwiftUI

struct OverviewStatsView: View {
    let stats: GeneralStats?
    let isLoading: Bool
    let range: TimeRange
    
    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView("Cargando...")
                    .padding()
            } else if let stats = stats {
                VStack(spacing: 20) {
                    // Resumen
                    HStack(spacing: 12) {
                        statCard(
                            title: "Completados",
                            value: "\(stats.totalCompleted)",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        
                        statCard(
                            title: "Esperados",
                            value: "\(stats.totalExpected)",
                            icon: "target",
                            color: .blue
                        )
                    }
                    
                    // Gráfico según rango
                    if range == .day {
                        // Vista diaria: Donut chart
                        DonutChartView(
                            completed: stats.totalCompleted,
                            expected: stats.totalExpected
                        )
                    } else {
                        // Vista semanal: Cards + Barras
                        statCard(
                            title: "Cumplimiento",
                            value: "\(Int(stats.overallRate * 100))%",
                            icon: "chart.bar.fill",
                            color: .orange,
                            fullWidth: true
                        )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tendencia")
                                .font(.headline)
                            
                            if !stats.periods.isEmpty {
                                StatsChartView(periods: stats.periods)
                            } else {
                                Text("Sin datos")
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                    }
                }
                .padding()
            } else {
                ContentUnavailableView(
                    "Sin estadísticas",
                    systemImage: "chart.bar",
                    description: Text("No hay datos disponibles")
                )
            }
        }
    }
    
    private func statCard(
        title: String,
        value: String,
        icon: String,
        color: Color,
        fullWidth: Bool = false
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title3.bold())
            }
            
            if !fullWidth {
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .frame(maxWidth: fullWidth ? .infinity : nil)
    }
}
