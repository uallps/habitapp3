import SwiftUI

struct StatsChartView: View {
    let periods: [PeriodData]
    @EnvironmentObject private var userPreferences: UserPreferences
    
    private let maxHeight: CGFloat = 100
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(periods) { period in
                    VStack(spacing: 4) {
                        // Barra
                        ZStack(alignment: .bottom) {
                            // Barra esperada (fondo - siempre 100%)
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: barHeightForExpected())
                            
                            // Barra completada (porcentaje del esperado)
                            Rectangle()
                                .fill(userPreferences.accentColor)
                                .frame(height: barHeight(for: period.completedCount, expected: period.expectedCount))
                        }
                        .frame(maxWidth: .infinity, maxHeight: maxHeight)
                        .cornerRadius(4)
                        
                        // Etiqueta
                        Text(period.label)
                            .font(.caption2)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
            }
            .frame(height: maxHeight + 30)
            
            // Leyenda
            HStack(spacing: 16) {
                Label("Completado", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(userPreferences.accentColor)
                
                Label("Esperado", systemImage: "circle")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                #if os(iOS)
                .fill(Color(.systemGray6))
                #else
                .fill(Color.clear)
                #endif
        )
    }
    
    private func barHeight(for count: Int, expected: Int) -> CGFloat {
        guard expected > 0 else { return 0 }
        let percentage = Double(count) / Double(expected)
        return CGFloat(percentage) * maxHeight
    }
    
    private func barHeightForExpected() -> CGFloat {
        return maxHeight
    }
}
