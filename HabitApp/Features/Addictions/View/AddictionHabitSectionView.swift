import SwiftUI

struct AddictionHabitSectionView: View {
    let config: AddictionHabitSectionConfig
    let availableHabits: [Habit]

    private let today = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Section(header: Text(config.title)) {
                if config.habits.isEmpty {
                    Text(config.emptyText)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(config.habits) { habit in
                        HStack {
                            Text(habit.title)

                            Button {
                                Task { await config.onTap(habit) }
                            } label: {
                                Image(systemName: habit.isCompletedForDate(today)
                                      ? "checkmark.circle.fill"
                                      : "circle")
                                    .foregroundColor(habit.isCompletedForDate(today) ? .green : .gray)
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)

                            Button {
                                Task { await config.onRemove(habit) }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            if !availableHabits.isEmpty {
                Section(header: Text("Añadir nuevo hábito")) {
                    ForEach(availableHabits) { habit in
                        Button("Añadir \(habit.title)") {
                            Task {
                                await config.onAssociate(habit)
                            }
                        }
                    }
                }
            }

        }
    }
}

