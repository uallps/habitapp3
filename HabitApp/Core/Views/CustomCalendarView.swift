import SwiftUI

struct CustomCalendarView: View {
    // El sistema Binding en SwiftUI es similar a los punteros en C o al manejo de estado en otros frameworks móviles como Jetpack Compose.

    // Para compararlos:
    // Puntero en C: "Te doy acceso a la memoria donde vive mi valor."
    // Binding de SwiftUI: "Te doy acceso controlado de lectura/escritura a mi valor."
    // (comportamiento similar a un puntero pero implementado con closures, no direcciones de memoria)

    // State hoisting en Jetpack Compose: "Te doy el valor y una función para cambiarlo, y cuando el valor cambia el componente padre se vuelve a renderizar."

    // SwiftUI es conceptualmente similar a pasar una "referencia a un valor", pero con tipado seguro, controlado y sin gestión manual de memoria.
    
    // ¿Qué es Binding en SwiftUI?
    // Un Binding<Value> es una conexión bidireccional entre un valor y una vista que lee y escribe ese valor.
    // El valor no se almacena en el @Binding en sí — pertenece a otro lugar (por ejemplo, a una variable @State, o a un @ObservedObject / @EnvironmentObject).
    // Cuando el valor vinculado cambia (vía el Binding), SwiftUI actualizará las vistas que dependen de ese valor. Igual que en Jetpack Compose.
    
    // Es como un puntero en C, porque proporciona acceso a un valor que pertenece a otro sitio, pero es como el state hoisting de Jetpack Compose
    // porque permite leer y escribir el valor, disparando actualizaciones de UI.
    
    // @Binding es un property wrapper que le dice a SwiftUI:
    // "No poseo este valor. Solo tengo una referencia a él, y puedo leerlo o escribirlo, pero pertenece a otra parte. Solo recibí este parámetro y conozco el valor."

    @Binding var selectedDate: Date
    
    // Sin embargo, esta es una variable @State porque es interna a esta vista. Esta vista posee este valor.
    // Podría pasarse desde este archivo a una vista hija de modo que si la vista hija lo cambia, esta vista se actualice.
    // Básicamente: "Oye, yo poseo este valor, pero si necesitas cambiarlo puedo pasártelo para que lo cambies y yo me actualice."
    @State private var displayedMonth: Date
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
    
    // Obtener el weekday del primer día del mes (1 = domingo, 7 = sábado)
    private var firstWeekday: Int {
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        let firstOfMonth = calendar.date(from: components)!
        return calendar.component(.weekday, from: firstOfMonth)
    }
    
    var body: some View {
        VStack {
            // Encabezado de navegación del mes
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
            
            // Etiquetas de los días de la semana
            let weekdaySymbols = calendar.shortStandaloneWeekdaySymbols
            HStack {
                ForEach(weekdaySymbols, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            // Rejilla de días con padding para el offset del primer weekday
            let columns = Array(repeating: GridItem(.flexible()), count: daysInWeek)
            
            LazyVGrid(columns: columns, spacing: 10) {
                // Espacios vacíos iniciales para compensar el primer día de la semana
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

