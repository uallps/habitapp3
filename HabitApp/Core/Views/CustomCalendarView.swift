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

    let doneDays: [Day]
    
    private let calendar = Calendar.current
    private let daysInWeek = 7
    
    init(selectedDate: Binding<Date>, doneDays: [Day]) {
        self._selectedDate = selectedDate
        self.doneDays = doneDays
        // Inicializa displayedMonth al inicio del mes para selectedDate
        _displayedMonth = State(initialValue: calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate.wrappedValue))!)
    }
    
    // Obtener todos los días del mes actualmente mostrado
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
        guard let firstOfMonth = calendar.date(from: components) else { return 1 }
        return calendar.component(.weekday, from: firstOfMonth)
    }
    
    var body: some View {
        VStack {
            // Encabezado de navegación del mes
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
                    Text(" ")
                        .frame(width: 30, height: 30)
                }
                
                ForEach(days, id: \.self) { date in
                    let day = calendar.component(.day, from: date)
                    
                    // Rango permitido: desde hoy hasta 14 días en el futuro
                    let today = calendar.startOfDay(for: Date())
                    let maxSelectableDate = calendar.date(byAdding: .day, value: 0, to: today)!
                    let isDisabled = date < today || date > maxSelectableDate
                    
                    VStack {
                        Text("\(day)")
                            .frame(width: 30, height: 30)
                            .background(
                                Circle()
                                    .fill(calendar.isDate(date, inSameDayAs: selectedDate) ? Color.blue : Color.clear)
                            )
                            .foregroundColor(
                                isDisabled ? .gray :
                                (calendar.isDate(date, equalTo: today, toGranularity: .day) ? .red : .primary)
                            )
                            .opacity(isDisabled ? 0.4 : 1)
                            .overlay(
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 6, height: 6)
                                    .offset(x: 10, y: 10)
                                    .opacity(doneDays.contains(where: { $0.isSameDay(as: date) }) ? 1 : 0)
                            )
                            .onTapGesture {
                                if !isDisabled {
                                       // Si el usuario toca el mismo día, deselecciona
                                       if calendar.isDate(date, inSameDayAs: selectedDate) {
                                           selectedDate = Date.distantPast // valor “nulo” simbólico
                                       } else {
                                           selectedDate = date
                                       }
                                   } else {
                                       print("❌ Fecha fuera del rango permitido")
                                   }
                            }
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
            
            if !calendar.isDate(selectedDate, equalTo: newMonth, toGranularity: .month) {
                selectedDate = newMonth
            }
        }
    }
}

extension Day {
    // date es la etiqueta externa; date es el nombre local del parámetro
    func isSameDay(as date: Date) -> Bool {
        let calendar = Calendar.current
        return self.day.value == calendar.component(.day, from: date) &&
               self.month.value == calendar.component(.month, from: date) &&
               self.year.value == calendar.component(.year, from: date)
    }
}
