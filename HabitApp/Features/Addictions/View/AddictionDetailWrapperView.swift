import SwiftUI
import SwiftData

struct AddictionDetailWrapperView: View {
    @Environment(\.dismiss) private var dismiss
    let addictionListVM: AddictionListViewModel

    @State private var showingRelapseAlert = false
    @State private var selectedTrigger: Habit?

    @Query(sort: \Habit.title, order: .forward) private var habitsQuery: [Habit]
    
    // Estados locales
    @State private var title: String
    @State private var selectedDays: [Int]
    @State private var severity: Addiction.AddictionSeverity
    @State private var addictionToEdit: Addiction?
    @State private var hasAddedNewTrigger: Bool = false
    @State private var hasAddedNewPreventionHabit: Bool = false
    @State private var hasAddedNewCompensatoryHabit: Bool = false

    @StateObject var habitListVM: HabitListViewModel
    let isNew: Bool

    @State private var showingNewHabitSheet = false
    
    init(addictionListVM: AddictionListViewModel, addiction: Addiction, isNew: Bool = true) {
        self.addictionListVM = addictionListVM
        self.isNew = isNew
        self._habitListVM = StateObject(wrappedValue: HabitListViewModel(storageProvider: addictionListVM.storageProvider))
        self._title = State(initialValue: addiction.title)
        self._severity = State(initialValue: addiction.severity)
        // selectedDays is not part of Addiction model; keep it empty by default
        self._selectedDays = State(initialValue: [])
        self._addictionToEdit = State(initialValue: isNew ? nil : addiction)
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
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "flag.fill")
                    .foregroundColor(.red)
                Text("Severidad de la adicción")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Picker("Severidad", selection: $severity) {
                ForEach(Addiction.AddictionSeverity.allCases, id: \.self) { sev in
                    Text(sev.displayName).tag(sev)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(16)
        #if os(iOS)
        .background(Color(.systemBackground))
        #endif
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    @ViewBuilder
    var triggerHabitsSection: some View {
        let today = Date()
        VStack(alignment: .leading, spacing: 12) {
            Section(header: Text("Hábitos desencadenantes asociados")) {
                if addictionToEdit?.triggers.isEmpty ?? true {
                    Text("No hay hábitos de prevención asociados.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(addictionToEdit?.triggers ?? []) { trigger in
                        HStack {
                            Text(trigger.title)
                            Spacer()
                            // Botón para marcar hábito a adicción (posible recaída)
                            Button(action: {
                                selectedTrigger = trigger
                                showingRelapseAlert = true
                            }) {
                                Image(systemName: trigger.isCompletedForDate(today) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(trigger.isCompletedForDate(today) ? .green : .gray)
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)

                            // Desasociar hábito desencadenante
                            Button(action: {
                                guard let addiction = addictionToEdit else { return }
                                Task {
                                    await addictionListVM.removeTriggerHabit(from: addiction, habit: trigger)
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            Section(header: Text("Añadir nuevo hábito desencadenante")) {
                ForEach(habitsQuery) { habit in
                    Button(action: {
                        guard let addiction = addictionToEdit else { return }
                        Task {
                            await addictionListVM.addTriggerHabit(to: addiction, habit: habit)
                            hasAddedNewTrigger = true
                        }
                    }) {
                        Text("Añadir \(habit.title)")
                    }
                }
            }
        }
        .alert("Posible recaída", isPresented: $showingRelapseAlert) {
            Button("Sí, he recaído", role: .destructive) {
                if let trigger = selectedTrigger, let addiction = addictionToEdit {
                    Task {
                        await addictionListVM.associateTriggerHabit(to: addiction, habit: trigger)
                    }
                }
            }
            Button("No, solo fue un riesgo") {
                // No-op
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("¿Este hábito desencadenó una recaída hoy?")
        }
    }

    @ViewBuilder
    var preventionHabitsSection: some View {
        let today = Date()
        VStack(alignment: .leading, spacing: 12) {
            Section(header: Text("Hábitos preventivos creados")) {
                if addictionToEdit?.preventionHabits.isEmpty ?? true {
                    Text("No hay hábitos de prevención asociados.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(addictionToEdit?.preventionHabits ?? []) { preventionHabit in
                        HStack {
                            Text(preventionHabit.title)
                            Spacer()
                            // Botón para marcar hábito preventivo (asociación)
                            Button(action: {
                                guard let addiction = addictionToEdit else { return }
                                Task {
                                    await addictionListVM.associatePreventionHabit(to: addiction, habit: preventionHabit)
                                }
                            }) {
                                Image(systemName: preventionHabit.isCompletedForDate(today) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(preventionHabit.isCompletedForDate(today) ? .green : .gray)
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)

                            // Desasociar hábito preventivo
                            Button(action: {
                                guard let addiction = addictionToEdit else { return }
                                Task {
                                    await addictionListVM.removePreventionHabit(from: addiction, habit: preventionHabit)
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            Section(header: Text("Añadir nuevo hábito preventivo")) {
                ForEach(habitsQuery) { habit in
                    Button(action: {
                        guard let addiction = addictionToEdit else { return }
                        Task {
                            await addictionListVM.addPreventionHabit(to: addiction, habit: habit)
                            hasAddedNewPreventionHabit = true
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
        let today = Date()
        VStack(alignment: .leading, spacing: 12) {
            Section(header: Text("Hábitos compensatorios creados")) {
                if addictionToEdit?.compensatoryHabits.isEmpty ?? true {
                    Text("No hay hábitos de compensatorios asociados.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(addictionToEdit?.compensatoryHabits ?? []) { compensatoryHabit in
                        HStack {
                            Text(compensatoryHabit.title)
                            Spacer()
                            // Botón para marcar hábito compensatorio (asociación)
                            Button(action: {
                                guard let addiction = addictionToEdit else { return }
                                Task {
                                    await addictionListVM.associateCompensatoryHabit(to: addiction, habit: compensatoryHabit)
                                }
                            }) {
                                Image(systemName: compensatoryHabit.isCompletedForDate(today) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(compensatoryHabit.isCompletedForDate(today) ? .green : .gray)
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)

                            // Desasociar hábito compensatorio
                            Button(action: {
                                guard let addiction = addictionToEdit else { return }
                                Task {
                                    await addictionListVM.removeCompensatoryHabit(from: addiction, habit: compensatoryHabit)
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            Section(header: Text("Añadir nuevo hábito compensatorio")) {
                ForEach(habitsQuery) { habit in
                    Button(action: {
                        guard let addiction = addictionToEdit else { return }
                        Task {
                            await addictionListVM.addCompensatoryHabit(to: addiction, habit: habit)
                            hasAddedNewCompensatoryHabit = true
                        }
                    }) {
                        Text("Añadir \(habit.title)")
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func saveAddiction() {
        Task {
            if let existing = addictionToEdit, !isNew {
                existing.title = title
                existing.severity = severity
                await addictionListVM.updateAddiction(addiction: existing)
            } else {
                let newAddiction = Addiction(
                    title: title,
                    severity: severity,
                    triggers: [],
                    preventionHabits: [],
                    compensatoryHabits: []
                )
                await addictionListVM.addAddiction(addiction: newAddiction)
                addictionToEdit = newAddiction
            }
            await MainActor.run {
                dismiss()
            }
        }
    }

    private func deleteAddiction() {
        guard let addiction = addictionToEdit else { return }
        Task {
            await addictionListVM.deleteAddiction(addiction: addiction)
            await MainActor.run {
                dismiss()
            }
        }
    }
}

// MARK: - iOS UI
#if os(iOS)
extension AddictionDetailWrapperView {
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
                            Button(action: saveAddiction) {
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
                            .disabled(title.isEmpty)

                            if !isNew {
                                Button(action: deleteAddiction) {
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
extension AddictionDetailWrapperView {
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
                            deleteAddiction()
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
                    .disabled(title.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(minWidth: 450, minHeight: 380)
    }
}
#endif
