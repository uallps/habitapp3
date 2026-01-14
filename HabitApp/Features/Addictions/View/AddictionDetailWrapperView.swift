import SwiftUI
import _SwiftData_SwiftUI

struct AddictionDetailWrapperView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var habitsQuery: [Habit] = []
    @State private var selectedDays: [Int]
    @State private var showRelapseAlert: Bool = false
    @State private var showWrongDayAlert: Bool = false
    @State private var currentDate = Date()

    let addictionListVM: AddictionListViewModel
    let habitListVM: HabitListViewModel
    let isNew: Bool

    @State private var title: String
    @State private var severity: AddictionSeverity
    @State private var addictionToEdit: Addiction?

    @Query(sort: \Habit.title, order: .forward)
    private var habitsQueryAll: [Habit]

    init(addictionListVM: AddictionListViewModel,
         addiction: Addiction,
         isNew: Bool = true,
         habitListVM: HabitListViewModel
    ) {

        self.addictionListVM = addictionListVM
        self.habitListVM = habitListVM
        self.isNew = isNew

        _title = State(initialValue: addiction.title)
        _severity = State(initialValue: addiction.severity)
        _addictionToEdit = State(initialValue: isNew ? nil : addiction)
        _selectedDays = State(initialValue: addiction.selectedDays)
    }

    // MARK: - Section Configurations

    private var triggerConfig: AddictionHabitSectionConfig? {
        guard let addiction = addictionToEdit else { return nil }

        return AddictionHabitSectionConfig(
            title: "Hábitos desencadenantes",
            emptyText: "No hay hábitos desencadenantes asociados.",
            habits: addiction.triggers,
            onAssociate: { habit, availableHabits in
                await addictionListVM.associateTriggerHabit(to: addiction, habit: habit)
                let index = availableHabits.firstIndex(of: habit)
                if index == nil { return }
                habitsQuery.remove(at: index!)
            },
            onRemove: { habit, availableHabits in
                await addictionListVM.removeTriggerHabit(from: addiction, habit: habit)
                habitsQuery.append(habit)
            },
            onTap: { habit, availableHabits in
                if habit.isScheduled(for: currentDate) {
                    habitListVM.toggleCompletion(habit: habit)
                } else {
                    showWrongDayAlert = false
                }
            }

        )
    }

    private var preventionConfig: AddictionHabitSectionConfig? {
        guard let addiction = addictionToEdit else { return nil }

        return AddictionHabitSectionConfig(
            title: "Hábitos preventivos",
            emptyText: "No hay hábitos preventivos asociados.",
            habits: addiction.preventionHabits,
            onAssociate: { habit, availableHabits in
                await addictionListVM.associatePreventionHabit(to: addiction, habit: habit)
                let index = availableHabits.firstIndex(of: habit)
                if index == nil { return }
                habitsQuery.remove(at: index!)
            },
            onRemove: { habit, availableHabits in
                await addictionListVM.removePreventionHabit(from: addiction, habit: habit)
                habitsQuery.append(habit)
            },
            onTap: { habit, availableHabits in
                if habit.isScheduled(for: currentDate) {
                    habitListVM.toggleCompletion(habit: habit)
                } else {
                    showWrongDayAlert = true
                }
            }
        )
    }

    private var compensatoryConfig: AddictionHabitSectionConfig? {
        guard let addiction = addictionToEdit else { return nil }

        return AddictionHabitSectionConfig(
            title: "Hábitos compensatorios",
            emptyText: "No hay hábitos compensatorios asociados.",
            habits: addiction.compensatoryHabits,
            onAssociate: { habit, availableHabits in
                await addictionListVM.associateCompensatoryHabit(to: addiction, habit: habit)
                let index = availableHabits.firstIndex(of: habit)
                if index == nil { return }
                habitsQuery.remove(at: index!)
            },
            onRemove: { habit, availableHabits in
                await addictionListVM.removeCompensatoryHabit(from: addiction, habit: habit)
                habitsQuery.append(habit)
            },
            onTap: { habit, availableHabits in
                if habit.isScheduled(for: currentDate) {
                    habitListVM.toggleCompletion(habit: habit)
                } else {
                    showWrongDayAlert = false
                }
            }
        )
    }

    // MARK: - Shared Content

    private var content: some View {
        VStack(spacing: 24) {

            VStack(alignment: .leading, spacing: 8) {
                Text("Título")
                    .font(.headline)

                TextField("Ej: Fumar", text: $title)
                    .textFieldStyle(.roundedBorder)
            }
            
            Text(
                "Día actual: \(currentDate.formatted(.dateTime.day().weekday()))"
            )
            
            Text("Días en los que se repite la adicción")
            WeekdaySelector(
                selectedDays: $selectedDays
            )
            
            VStack(alignment: .leading, spacing: 12) {

                Picker("Severidad de adicción", selection: $severity) {
                    ForEach(AddictionSeverity.allCases, id: \.self) {
                        Text($0.displayName).tag($0)
                    }
                }
                .pickerStyle(.segmented)
            }
            

            if let triggerConfig {
                AddictionHabitSectionView(
                    config: triggerConfig,
                    availableHabits: $habitsQuery
                )
            }else {
                Text("Podrás asociar hábitos después de crear la adicción.")
            }

            if let preventionConfig {
                AddictionHabitSectionView(
                    config: preventionConfig,
                    availableHabits: $habitsQuery
                )
            }

            if let compensatoryConfig {
                AddictionHabitSectionView(
                    config: compensatoryConfig,
                    availableHabits: $habitsQuery
                )
            }

            HStack {
                Button("Cancelar") {
                    dismiss()
                }

                Spacer()

                if !isNew {
                    Button("Eliminar", role: .destructive) {
                        deleteAddiction()
                    }
                }

                Button(isNew ? "Crear" : "Guardar") {
                    saveAddiction()
                }
                .disabled(title.isEmpty)
            }
        }.alert("Has hecho el hábito que puede haberte hecho recaer.", isPresented: $showRelapseAlert) {
            Button("Sí") {
                Task {
                    if addictionToEdit != nil {
                        addictionToEdit!.relapseCount += 1
                        try await addictionListVM.updateAddiction(addiction: addictionToEdit!)
                    }
 
                }
            }

            Button("No", role: .cancel) {
            }
        } message: {
            Text("¿Has recaído?")
        
        }
        .alert("¡No se puede completar el hábito este día!", isPresented: $showWrongDayAlert) {
            Button("Vale", role: .cancel) {
                
            }
        }
        .task {
            await loadAddictionHabits()
        }
    }

    // MARK: - Actions

    private func saveAddiction() {
        Task {
            if let addiction = addictionToEdit {
                addiction.title = title
                addiction.severity = severity
                addiction.selectedDays = selectedDays
                await addictionListVM.updateAddiction(addiction: addiction)
            } else {
                let addiction = Addiction(
                    title: title,
                    severity: severity,
                    triggers: [],
                    preventionHabits: [],
                    compensatoryHabits: [],
                )
                addiction.selectedDays = selectedDays
                await addictionListVM.addAddiction(addiction: addiction)
                addictionToEdit = addiction
            }

            await MainActor.run { dismiss() }
        }
    }

    private func deleteAddiction() {
        guard let addiction = addictionToEdit else { return }

        Task {
            await addictionListVM.deleteAddiction(addiction: addiction)
            await MainActor.run { dismiss() }
        }
    }

    // MARK: - Platform Bodies

    var body: some View {
        #if os(iOS)
        ScrollView {
            content.padding()
        }
        #else
        content
            .padding()
            .frame(minWidth: 450, minHeight: 400)
        #endif
    }
    
    private func loadAddictionHabits() async {
        var result: [Habit] = []

        for habit in habitsQueryAll {
            result.append(habit)
        }

        await MainActor.run {
            habitsQuery = result
        }
    }
}

