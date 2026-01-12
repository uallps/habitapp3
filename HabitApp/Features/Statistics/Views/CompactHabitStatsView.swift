import SwiftUI

struct CompactHabitStatsView: View {
    let periods: [PeriodData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ForEach(periods) { period in
                    VStack(spacing: 4) {
                        // Círculo de progreso mini
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 3)
                                .frame(width: 30, height: 30)
                            
                            Circle()
                                .trim(from: 0, to: period.completionRate)
                                .stroke(completionColor(for: period.completionRate), lineWidth: 3)
                                .frame(width: 30, height: 30)
                                .rotationEffect(.degrees(-90))
                            
                            if period.completedCount == period.expectedCount && period.expectedCount > 0 {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.green)
                            }
                        }
                        
                        // Etiqueta del día
                        Text(period.label)
                            .font(.system(size: 9))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .foregroundColor(.secondary)
                    }
                }
                
                #if os(macOS)
                Spacer()
                #endif
            }
        }
        .padding(.vertical, 8)
    }
    
    private func completionColor(for rate: Double) -> Color {
        switch rate {
        case 1.0: return .green
        case 0.5..<1.0: return .blue
        case 0.01..<0.5: return .orange
        default: return .gray
        }
    }
}
