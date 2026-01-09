import SwiftUI
import SwiftData

struct AddictionDetailWrapperView: View {
    @Environment(\.dismiss) private var dismiss
    let addictionListVM: AddictionListViewModel

    @State private var showingRelapseAlert = false
    @State private var selectedTrigger: Habit?

    @Query(sort: \.title, order: .forward) private var habitsQuery: [Habit]
    
    //  Estados locales para evitar binding directo con @State var habit
    @State private var title: String
    @State private var selectedDays: [Int]
    @State private var severity: Addiction.AddictionSeverity
    @State private var addictionToEdit: Addiction?
    @State private var hasAddedNewTrigger: Bool = false
    @State private var hasAddedNewPreventionHabit: Bool = false
    @State private var hasAddedNewCompensatoryHabit: Bool = false

    @StateObject var habitListVM = HabitListViewModel()
    let isNew: Bool

    @State private var showingNewHabitSheet = false
    
    init(addictionListVM: HabitListViewModel, addiction: Addiction, isNew: Bool = true) {
        self.addictionListVM = viewModel
        self.isNew = isNew
        self.addictionToEdit = isNew ? nil : habit
        
        // Inicializar estados locales
        _title = State(initialValue: addiction.title)
    }

    var body: some View {
        #if os(iOS)
        iosBody
        #else
        macBody
        #endif
    }

    @ViewBuilder
    var addictionSeveritySection: some View {
                        //  Severidad de la adicción
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "flag.fill")
                                    .foregroundColor(.red)
                                Text("Severidad de la adicción")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            Picker("Severidad", selection: $severity) {
                                ForEach(AddictionSeverity.allCases, id: \.self) { severity in
                                    Text(severity.displayName).tag(severity)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(16)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)

                        Section() {
                            
                        }
    }

    @ViewBuilder
    var triggerHabitsSection: some View {
                                // Hábitos que desencadenan la adicción
                        VStack(alignment: .leading, spacing: 12) {
                            Section(header: Text("Hábitos desencadenantes asociados")) {
                                if addictionToEdit?.triggers.isEmpty ?? true {
                                    Text("No hay hábitos de prevención asociados.")
                                        .foregroundColor(.secondary)
                                } else {
                                    ForEach(addictionToEdit?.triggers ?? []) { trigger in
                                        HStack(
                                            Text(trigger.title),

                                            //  Botón para marcar hábito a adicción. Significado: "He hecho este hábito que me puede hacer recaer"
                                            Button(action: 
                                                       selectedTrigger = trigger,
                                                        showingRelapseAlert = true
                                                        // Ahora, ¿he recaído o no? Preguntar al usuario
                                            ) {
                                                Image(systemName: habit.isCompletedForDate(date) ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(habit.isCompletedForDate(date) ? .green : .gray)
                                                    .font(.title3)
                                            }
                                            .buttonStyle(.plain),

                                            // Desasociar hábito desencadenante
                                            Button(action:
                                                addictionListVM.removeTriggerHabit()
                                            ) {
                                                Image(systemName: "minus.circle.fill")
                                                    .foregroundColor(.red)
                                                    .font(.title3)
                                            }
                                            .buttonStyle(.plain)
                                        )
                                    }
                                }
                            }

                            Section(header: Text("Añadir nuevo hábito desencadenante")) {
                                ForEach(habitsQuery) { habit in
                                    Button(action: {
                                        Task {
                                            hasAddedNewTrigger = await addictionListVM.addTriggerHabit(
                                                
                                            )
                                        }
                                    }
                                    ) {
                                        Text("Añadir \(habit.title)")
                                    }
                                }
                            }

                        }
                                .alert("Posible recaída", isPresented: $showingRelapseAlert) {
            Button("Sí, he recaído", role: .destructive) {
                if let trigger = selectedTrigger {
                    addictionListVM.associateTriggerHabit(
                        to: adiction,
                        habit: trigger,
                    )
                }
            }

            Button("No, solo fue un riesgo") {

            }

            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("¿Este hábito desencadenó una recaída hoy?")
        }

    }

    @ViewBuilder
    var preventionHabitsSection: some View {
                                // Hábitos para prevenir la adicción
                        VStack(alignment: .leading, spacing: 12) {
                            Section(header: Text("Hábitos preventivos creados")) {
                                if addictionToEdit?.preventionHabits.isEmpty ?? true {
                                    Text("No hay hábitos de prevención asociados.")
                                        .foregroundColor(.secondary)
                                } else {
                                    ForEach(addictionToEdit?.preventionHabits ?? []) { preventionHabit in
                                        HStack(
                                            Text(trigger.title),

                                            //  Botón para marcar hábito a adicción. Significado: "Este hábito ha prevenido mi adicción hoy"
                                            Button(action: 
                                                    addictionListVM.associatePreventionHabit()
                                            ) {
                                                Image(systemName: habit.isCompletedForDate(date) ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(habit.isCompletedForDate(date) ? .green : .gray)
                                                    .font(.title3)
                                            }
                                            .buttonStyle(.plain),

                                            // Desasociar hábito preventivo
                                            Button(action:
                                                addictionListVM.removePreventionHabit()
                                            ) {
                                                Image(systemName: "minus.circle.fill")
                                                    .foregroundColor(.red)
                                                    .font(.title3)
                                            }
                                            .buttonStyle(.plain)
                                        )
                                    }
                                }
                            }

                            Section(header: Text("Añadir nuevo hábito preventivo")) {
                                ForEach(habitsQuery) { habit in
                                    Button(action: {
                                        Task {
                                            hasAddedNewPreventionHabit = await addictionListVM.addPreventionHabit(
                                                
                                            )
                                        }
                                    }) {
                                        Text("Añadir \(habit.title)")
                                    }
                                }
                            }

                        }
    }

    @ViewBuilder
    var compensatoryHabitsSection: some View {
                                // Hábitos que compensan la adicción
                        VStack(alignment: .leading, spacing: 12) {
                            Section(header: Text("Hábitos compensatorios creados")) {
                                if addictionToEdit?.compensatoryHabits.isEmpty ?? true {
                                    Text("No hay hábitos de compensatorios asociados.")
                                        .foregroundColor(.secondary)
                                } else {
                                    ForEach(addictionToEdit?.compensatoryHabits ?? []) { compensatoryHabits in
                                        HStack(
                                            Text(trigger.title),

                                            //  Botón para marcar hábito a adicción. Significado: "He caído en mi adicción, pero este hábito me ha ayudado a compensarlo"
                                            Button(action: 
                                                    addictionListVM.associateCompensatoryHabit()
                                            ) {
                                                Image(systemName: habit.isCompletedForDate(date) ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(habit.isCompletedForDate(date) ? .green : .gray)
                                                    .font(.title3)
                                            }
                                            .buttonStyle(.plain),

                                            // Desasociar hábito compensatorio
                                            Button(action:
                                                addictionListVM.removeCompensatoryHabit(

                                                )
                                            ) {
                                                Image(systemName: "minus.circle.fill")
                                                    .foregroundColor(.red)
                                                    .font(.title3)
                                            }
                                            .buttonStyle(.plain)
                                        )
                                    }
                                }
                            }

                            Section(header: Text("Añadir nuevo hábito compensatorio")) {
                                ForEach(habitsQuery) { habit in
                                    Button(action: {
                                        Task {
                                            hasAddedNewCompensatoryHabit = await addictionListVM.addCompensatoryHabit(

                                            )
                                        }
                                    }) {
                                        Text("Añadir \(habit.title)")
                                    }
                                }
                            }

                        }
    }
}

// MARK: - iOS UI
#if os(iOS)
extension HabitDetailWrapper {
    var iosBody: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.05),
                        Color.purple.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        //  Título
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "text.cursor")
                                    .foregroundColor(.blue)
                                Text("Título")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            TextField("Ej: Fumar", text: $title)
                                .textFieldStyle(.roundedBorder)
                                .font(.body)
                        }
                        .padding(16)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        
                        //  Días de la semana
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.orange)
                                Text("Días de la semana")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            WeekdaySelector(selectedDays: $selectedDays)
                                .padding(.vertical, 4)
                        }
                        .padding(16)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)



                        addictionSeveritySection
                        triggerHabitsSection
                        preventionHabitsSection
                        compensatoryHabitsSection



                        //  Botones
                        VStack(spacing: 12) {
                            Button(action: saveHabit) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text(isNew ? "Crear adicción" : "Guardar cambios")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                            .disabled(title.isEmpty || selectedDays.isEmpty)
                            
                            if !isNew {
                                Button(action: deleteHabit) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "trash.fill")
                                        Text("Eliminar adicción")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: Color.red.opacity(0.3), radius: 4, x: 0, y: 2)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(16)
                }
            }
            .navigationTitle(isNew ? "Nueva adicción" : "Editar adicción")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
#endif

// MARK: - macOS UI
#if os(macOS)
extension HabitDetailWrapper {
    var macBody: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.08),
                    Color.purple.opacity(0.08)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isNew ? "Nueva adicción" : "Editar adicción")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Configura los detalles de tu adicción")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 16) {
                    // Título
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "text.cursor")
                                .foregroundColor(.blue)
                            Text("Título de la adicción")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        TextField("Ej: Fumar", text: $title)
                            .textFieldStyle(.roundedBorder)
                            .font(.body)
                    }
                    .padding(12)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(10)
                    
                    // Días de la semana
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .foregroundColor(.orange)
                            Text("Días de la semana")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        WeekdaySelector(selectedDays: $selectedDays)
                            .padding(.vertical, 4)
                    }
                    .padding(12)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 20)

                        addictionSeveritySection
                        triggerHabitsSection
                        preventionHabitsSection
                        compensatoryHabitsSection
                
                Spacer()
                
                // Botones
                HStack(spacing: 12) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                    
                    Spacer()
                    
                    if !isNew {
                        Button("Eliminar") {
                            deleteHabit()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .controlSize(.large)
                    }
                    
                    Button(isNew ? "Crear" : "Guardar") {
                        saveAddiction()
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
                    .controlSize(.large)
                    .disabled(title.isEmpty || selectedDays.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(minWidth: 450, minHeight: 380)
    }
}
#endif
