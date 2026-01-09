import SwiftUI

struct CustomCalendarView: View {
    @Binding var selectedDate: Date
    let doneDates: [Date]   // <-- Ahora recibe fechas directamente
    
    @State private var displayedMonth: Date
    
    private let calendar = Calendar.current
    private let daysInWeek = 7
    
    init(selectedDate: Binding<Date>, doneDates: [Date]) {
        self._selectedDate = selectedDate
        self.doneDates = doneDates
        // Inicio del mes de la fecha seleccionada
        _displayedMonth = State(initialValue:
            Calendar.current.date(from:
                Calendar.current.dateComponents([.year, .month], from: selectedDate.wrappedValue)
            )!
        )
    }
    
    // Días del mes mostrado
    private var days: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else { return [] }
        var days: [Date] = []
        var currentDate = monthInterval.start
        
        while currentDate < monthInterval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return days
    }
    
    private var firstWeekday: Int {
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        let firstOfMonth = calendar.date(from: components)!
        return calendar.component(.weekday, from: firstOfMonth)
    }
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthYearString)
                    .font(.headline)
                Spacer()
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            // Weekdays
            let weekdaySymbols = calendar.shortStandaloneWeekdaySymbols
            HStack {
                ForEach(weekdaySymbols, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            let columns = Array(repeating: GridItem(.flexible()), count: daysInWeek)
            
            LazyVGrid(columns: columns, spacing: 10) {
                
                // Empty spaces before first day
                ForEach(0..<firstWeekday-1, id: \.self) { _ in
                    Text(" ").frame(width: 30, height: 30)
                }
                
                // Calendar days
                ForEach(days, id: \.self) { date in
                    let day = calendar.component(.day, from: date)
                    
                    let today = calendar.startOfDay(for: Date())
                    let isDisabled = date < today // Solo permite días a partir de hoy
                    
                    VStack {
                        Text("\(day)")
                            .frame(width: 30, height: 30)
                            .background(
                                Circle()
                                    .fill(calendar.isDate(date, inSameDayAs: selectedDate) ? Color.blue : .clear)
                            )
                            .foregroundColor(isDisabled ? .gray :
                                (calendar.isDate(date, inSameDayAs: today) ? .red : .primary)
                            )
                            .opacity(isDisabled ? 0.4 : 1)
                            .overlay(
                                // Punto verde si el día está marcado como hecho
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 6, height: 6)
                                    .offset(x: 10, y: 10)
                                    .opacity(
                                        doneDates.contains {
                                            calendar.isDate($0, inSameDayAs: date)
                                        } ? 1 : 0
                                    )
                            )
                            .onTapGesture {
                                if !isDisabled {
                                    // Deselección si toca el mismo día
                                    if calendar.isDate(date, inSameDayAs: selectedDate) {
                                        selectedDate = Date.distantPast
                                    } else {
                                        selectedDate = date
                                    }
                                }
                            }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: Helpers
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: displayedMonth)
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newMonth
            // Ajustar fecha seleccionada al mes nuevo si no coincide
            if !calendar.isDate(selectedDate, equalTo: newMonth, toGranularity: .month) {
                selectedDate = newMonth
            }
        }
    }
}
