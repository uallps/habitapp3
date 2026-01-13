import SwiftUI

struct DonutChartView: View {
    let completed: Int
    let expected: Int
    @EnvironmentObject private var userPreferences: UserPreferences
    
    private var percentage: Double {
        guard expected > 0 else { return 0 }
        return Double(completed) / Double(expected)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Círculo de fondo
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 150, height: 150)
                
                // Círculo de progreso
                Circle()
                    .trim(from: 0, to: percentage)
                    .stroke(
                        LinearGradient(
                            colors: [userPreferences.accentColor, .green],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6), value: percentage)
                
                // Porcentaje en el centro
                VStack(spacing: 4) {
                    Text("\(Int(percentage * 100))%")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("\(completed)/\(expected)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Leyenda
            HStack(spacing: 20) {
                Label("\(completed) Completados", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(userPreferences.accentColor)
                
                Label("\(expected - completed) Pendientes", systemImage: "circle")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        #if os(macOS)
        .frame(maxWidth: 400, alignment: .leading)
        #endif
        .background(
            RoundedRectangle(cornerRadius: 12)
            #if os(iOS)
                .fill(Color(.systemGray6))
            #else
                .fill(Color.clear)
            #endif
        )
    }
}
