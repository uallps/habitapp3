import SwiftUI

struct StatsChartView: View {
    let periods: [PeriodData]
    
    private let maxHeight: CGFloat = 100
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(periods) { period in
                    VStack(spacing: 4) {
                        // Barra
                        ZStack(alignment: .bottom) {
                            // Barra esperada (fondo)
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: barHeight(for: period.expectedCount))
                            
                            // Barra completada (sobre)
                            Rectangle()
                                .fill(Color.blue)
                                .frame(height: barHeight(for: period.completedCount))
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
                    .foregroundColor(.blue)
                
                Label("Esperado", systemImage: "circle")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    private func barHeight(for count: Int) -> CGFloat {
        let maxCount = periods.map { max($0.completedCount, $0.expectedCount) }.max() ?? 1
        guard maxCount > 0 else { return 0 }
        return CGFloat(count) / CGFloat(maxCount) * maxHeight
    }
}
