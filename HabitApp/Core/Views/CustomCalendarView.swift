import SwiftUI

struct CustomCalendarView: View {
    @Binding var selectedDate: Date
    let doneDays: [Day]
    
    @State private var displayedMonth: Date  // Track current displayed month
    
    private let calendar = Calendar.current
    private let daysInWeek = 7
    
    init(selectedDate: Binding<Date>, doneDays: [Day]) {
        self._selectedDate = selectedDate
        self.doneDays = doneDays
        // Initialize displayedMonth to the start of the month for selectedDate
        _displayedMonth = State(initialValue: calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate.wrappedValue))!)
    }
    
    // Get all days for the current displayed month
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
    
    // Get the weekday of the first day of the month (1 = Sunday, 7 = Saturday in most calendars)
    private var firstWeekday: Int {
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstOfMonth = calendar.date(from: components) else { return 1 }
        return calendar.component(.weekday, from: firstOfMonth)
    }
    
    var body: some View {
        VStack {
            // Month navigation header
            HStack {
                Button(action: {
                    changeMonth(by: -1)
                }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthYearString)
                    .font(.headline)
                Spacer()
                Button(action: {
                    changeMonth(by: 1)
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            // Weekday labels
            let weekdaySymbols = calendar.shortStandaloneWeekdaySymbols
            HStack {
                ForEach(weekdaySymbols, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            // Days grid with padding for the first weekday
            let columns = Array(repeating: GridItem(.flexible()), count: daysInWeek)
            
            LazyVGrid(columns: columns, spacing: 10) {
                // Padding empty spaces for first weekday offset
                ForEach(0..<firstWeekday-1, id: \.self) { _ in
                    Text(" ")
                        .frame(width: 30, height: 30)
                }
                
                ForEach(days, id: \.self) { date in
                    let day = calendar.component(.day, from: date)
                    
                    VStack {
                        Text("\(day)")
                            .frame(width: 30, height: 30)
                            .background(
                                Circle()
                                    .fill(calendar.isDate(date, inSameDayAs: selectedDate) ? Color.blue : Color.clear)
                            )
                            .foregroundColor(calendar.isDate(date, equalTo: Date(), toGranularity: .day) ? .red : .primary)
                            .overlay(
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 6, height: 6)
                                    .offset(x: 10, y: 10)
                                    .opacity(doneDays.contains(where: { $0.isSameDay(as: date) }) ? 1 : 0)
                            )
                    }
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }
            .padding()
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: displayedMonth)
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newMonth
            
            // Optionally reset selectedDate to the first day of the new month or keep it unchanged
            // Here we just keep selectedDate if it’s still in the new month; otherwise reset to newMonth start
            if !calendar.isDate(selectedDate, equalTo: newMonth, toGranularity: .month) {
                selectedDate = newMonth
            }
        }
    }
}

// Your Day model extension remains the same
extension Day {
    func isSameDay(as date: Date) -> Bool {
        let calendar = Calendar.current
        return self.day.value == calendar.component(.day, from: date) &&
               self.month.value == calendar.component(.month, from: date) &&
               self.year.value == calendar.component(.year, from: date)
    }
}
