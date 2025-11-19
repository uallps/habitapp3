import SwiftUI

struct HabitDetailView: View {
    @Binding var habit: Habit
    @State private var selectedDate = Date()
    
    private let calendar = Calendar.current
    private let weekdaySymbols = Calendar.current.shortStandaloneWeekdaySymbols
    
    var body: some View {
        Form {
            Section(header: Text("Detalles del hábito")) {
                TextField("Título del hábito", text: $habit.title)
            }
            
            Section(header: Text("Días de la semana")) {
                HStack {
                    ForEach(1...7, id: \.self) { index in
                        let dayName = weekdaySymbols[index - 1]
                        let isSelected = habit.scheduledDays.contains(index)
                        
                        Button(action: {
                            toggleDay(index)
                        }) {
                            Text(dayName.prefix(2)) // Lu, Ma, Mi, etc.
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.3))
                                )
                                .foregroundColor(.white)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 6)
            }
            
        }
        .navigationTitle(habit.title)
    }
    
    private func toggleDay(_ index: Int) {
        if let i = habit.scheduledDays.firstIndex(of: index) {
            habit.scheduledDays.remove(at: i)
        } else {
            habit.scheduledDays.append(index)
        }
    }
}
