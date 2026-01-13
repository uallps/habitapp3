import SwiftUI
import SwiftData

struct AddGoalView: View {
    let habits: [Habit]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var title = ""
    @State private var description = ""
    @State private var targetCount = 30
    @State private var targetDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var selectedHabit: Habit?
    @State private var milestones: [MilestoneInput] = []
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.06),
                    Color.purple.opacity(0.06)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Información del Objetivo
                        SectionCard(title: "Información del Objetivo", icon: "target") {
                            VStack(spacing: 12) {
                                TextField("Título", text: $title)
                                    .textFieldStyle(.roundedBorder)
                                
                                TextField("Descripción (opcional)", text: $description)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        
                        // Meta
                        SectionCard(title: "Meta", icon: "calendar.badge.clock") {
                            VStack(spacing: 14) {
                                HStack {
                                    Label("Días objetivo", systemImage: "number.circle.fill")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                    Spacer()
                                    Stepper("\(targetCount)", value: $targetCount, in: 1...365)
                                }
                                
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Fecha límite", systemImage: "calendar")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                    
                                    DatePicker(
                                        "Seleccionar fecha",
                                        selection: $targetDate,
                                        in: Date()...,
                                        displayedComponents: .date
                                    )
                                    .datePickerStyle(.compact)
                                }
                            }
                        }
                        
                        // Hábito Asociado
                        habitSelector
                        
                        // Hitos
                        milestonesSection
                    }
                    .padding(.horizontal, isCompact ? 16 : 24)
                    .padding(.vertical, 20)
                }
                .navigationTitle("Nuevo Objetivo")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    #if os(iOS)
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancelar") { dismiss() }
                            .foregroundColor(.blue)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Guardar") { saveGoal() }
                            .disabled(title.isEmpty || selectedHabit == nil)
                            .fontWeight(.semibold)
                    }
                    #else
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") { dismiss() }
                    }
                    
                    ToolbarItem(placement: .primaryAction) {
                        Button("Guardar") { saveGoal() }
                            .disabled(title.isEmpty || selectedHabit == nil)
                            .fontWeight(.semibold)
                    }
                    #endif
                }
            }
        }
    }
    
    @ViewBuilder
    private var habitSelector: some View {
        SectionCard(title: "Hábito Asociado *", icon: "bolt.fill") {
            if habits.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "bolt.slash")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    Text("No hay hábitos disponibles")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else if selectedHabit == nil {
                habitListView
            } else {
                selectedHabitView
            }
        }
    }
    
    private var habitListView: some View {
        VStack(spacing: 8) {
            ForEach(habits) { habit in
                HabitSelectButton(habit: habit, action: { selectedHabit = habit })
            }
            
            Button {
                selectedHabit = nil
            } label: {
                Label("Ninguno", systemImage: "xmark.circle.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            }
        }
    }
    
    private var selectedHabitView: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(selectedHabit!.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 6) {
                        ForEach(selectedHabit!.scheduledDays, id: \.self) { day in
                            Text(dayName(for: day))
                                .font(.caption2)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.15))
                                .cornerRadius(4)
                        }
                    }
                    
                    if let priority = selectedHabit!.priority {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.caption)
                            Text("Prioridad: \(priority.localized)")
                                .font(.caption)
                        }
                        .foregroundColor(priorityColor(for: priority))
                    }
                }
                
                Spacer()
                
                Button {
                    selectedHabit = nil
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                }
            }
            .padding(12)
            .background(Color.blue.opacity(0.06))
            .cornerRadius(10)
        }
    }
    
    private var milestonesSection: some View {
        SectionCard(title: "Hitos (opcional)", icon: "flag.fill") {
            VStack(spacing: 10) {
                if milestones.isEmpty {
                    Text("Agrega hitos para marcar progreso")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                } else {
                    ForEach(milestones.indices, id: \.self) { index in
                        MilestoneInputRow(
                            milestone: $milestones[index],
                            maxValue: targetCount,
                            onDelete: { milestones.remove(at: index) }
                        )
                    }
                }
                
                Button {
                    milestones.append(MilestoneInput(title: "", value: targetCount / 2))
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.subheadline)
                        Text("Agregar Hito")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 10)
                }
            }
        }
    }
    
    private func saveGoal() {
        let goal = Goal(
            title: title,
            description: description,
            targetCount: targetCount,
            targetDate: targetDate,
            habitId: selectedHabit?.id
        )
        
        for milestoneInput in milestones where !milestoneInput.title.isEmpty {
            let milestone = Milestone(
                title: milestoneInput.title,
                targetValue: milestoneInput.value,
                goal: goal
            )
            modelContext.insert(milestone)
        }
        
        modelContext.insert(goal)
        try? modelContext.save()
        dismiss()
    }
    
    private func dayName(for weekday: Int) -> String {
        let dayNames = ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"]
        return dayNames[weekday - 1]
    }
    
    private func priorityColor(for priority: Priority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

// MARK: - Componentes Reutilizables
struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                #if os(iOS)
                .fill(Color(.systemGray6))
                #else
                .fill(Color(.controlBackgroundColor))
                #endif
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
    }
}

struct HabitSelectButton: View {
    let habit: Habit
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(habit.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        ForEach(habit.scheduledDays, id: \.self) { day in
                            Text(dayName(for: day))
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(3)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }
    
    private func dayName(for weekday: Int) -> String {
        let dayNames = ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"]
        return dayNames[weekday - 1]
    }
}

struct MilestoneInputRow: View {
    @Binding var milestone: MilestoneInput
    let maxValue: Int
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Hito", text: $milestone.title)
                .textFieldStyle(.roundedBorder)
                .font(.subheadline)
            
            HStack(spacing: 8) {
                Stepper("", value: $milestone.value, in: 1...maxValue)
                    .labelsHidden()
                
                Text("\(milestone.value)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .frame(width: 30)
            }
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.subheadline)
                    .foregroundColor(.red.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }
}

struct MilestoneInput {
    var title: String
    var value: Int
}