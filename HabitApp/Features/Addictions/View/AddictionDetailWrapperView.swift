import SwiftUI
import _SwiftData_SwiftUI

struct AddictionDetailWrapperView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var habitsQuery: [Habit] = []
    @State private var selectedDays: [Int]

    let addictionListVM: AddictionListViewModel
    let isNew: Bool

    @State private var title: String
    @State private var severity: AddictionSeverity
    @State private var addictionToEdit: Addiction?

    @Query(sort: \Habit.title, order: .forward)
    private var habitsQueryAll: [Habit]

    init(addictionListVM: AddictionListViewModel,
         addiction: Addiction,
         isNew: Bool = true
    ) {

        self.addictionListVM = addictionListVM
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
            onAssociate: { habit in
                await addictionListVM.associateTriggerHabit(to: addiction, habit: habit)
            },
            onRemove: { habit in
                await addictionListVM.removeTriggerHabit(from: addiction, habit: habit)
            },
            onAdd: { habit in
                await addictionListVM.addTriggerHabit(to: addiction, habit: habit)
            }
        )
    }

    private var preventionConfig: AddictionHabitSectionConfig? {
        guard let addiction = addictionToEdit else { return nil }

        return AddictionHabitSectionConfig(
            title: "Hábitos preventivos",
            emptyText: "No hay hábitos preventivos asociados.",
            habits: addiction.preventionHabits,
            onAssociate: { habit in
                await addictionListVM.associatePreventionHabit(to: addiction, habit: habit)
            },
            onRemove: { habit in
                await addictionListVM.removePreventionHabit(from: addiction, habit: habit)
            },
            onAdd: { habit in
                await addictionListVM.addPreventionHabit(to: addiction, habit: habit)
            }
        )
    }

    private var compensatoryConfig: AddictionHabitSectionConfig? {
        guard let addiction = addictionToEdit else { return nil }

        return AddictionHabitSectionConfig(
            title: "Hábitos compensatorios",
            emptyText: "No hay hábitos compensatorios asociados.",
            habits: addiction.compensatoryHabits,
            onAssociate: { habit in
                await addictionListVM.associateCompensatoryHabit(to: addiction, habit: habit)
            },
            onRemove: { habit in
                await addictionListVM.removeCompensatoryHabit(from: addiction, habit: habit)
            },
            onAdd: { habit in
                await addictionListVM.addCompensatoryHabit(to: addiction, habit: habit)
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
                    availableHabits: habitsQuery
                )
            }else {
                Text("Podrás asociar hábitos después de crear la adicción.")
            }

            if let preventionConfig {
                AddictionHabitSectionView(
                    config: preventionConfig,
                    availableHabits: habitsQuery
                )
            }

            if let compensatoryConfig {
                AddictionHabitSectionView(
                    config: compensatoryConfig,
                    availableHabits: habitsQuery
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
        }.task {
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
                    addiction: Habit(title: title)
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
        NavigationStack {
            ScrollView {
                content.padding()
            }
            .navigationTitle(isNew ? "Nueva adicción" : "Editar adicción")
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
            if try await !addictionListVM.isHabitAddiction(habit: habit) {
                result.append(habit)
            }
        }

        await MainActor.run {
            habitsQuery = result
        }
    }
}

