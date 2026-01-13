import SwiftUI
import SwiftData
import Combine

struct GoalDetailView: View {
    @Bindable var goal: Goal
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject private var viewModel: GoalsViewModel
    @State private var associatedHabit: Habit?
    @State private var refreshTrigger = UUID()
    @State private var timer: AnyCancellable?
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    init(goal: Goal, storageProvider: StorageProvider) {
        self._goal = Bindable(goal)
        _viewModel = StateObject(wrappedValue: GoalsViewModel(storageProvider: storageProvider))
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
            
            if isCompact {
                compactContent
            } else {
                regularContent
            }
        }
        .navigationTitle(goal.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            loadAssociatedHabit()
            startAutoRefresh()
        }
        .onDisappear {
            timer?.cancel()
        }
        .id(refreshTrigger)
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                deleteMenu
            }
            #else
            ToolbarItem(placement: .primaryAction) {
                deleteMenu
            }
            #endif
        }
    }
    
    private var deleteMenu: some View {
        Menu {
            Button(role: .destructive) {
                modelContext.delete(goal)
                try? modelContext.save()
                dismiss()
            } label: {
                Label("Eliminar", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
    
    private var compactContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard
                progressCard
                dateInfoCard
                
                if let habit = associatedHabit {
                    habitCard(habit: habit)
                }
                
                if !goal.milestones.isEmpty {
                    milestonesCard
                }
                
                Spacer()
            }
            .padding(16)
        }
    }
    
    private var regularContent: some View {
        ScrollView {
            HStack(alignment: .top, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    headerCard
                    dateInfoCard
                    Spacer()
                }
                .frame(maxWidth: 280)
                
                VStack(alignment: .leading, spacing: 16) {
                    progressCard
                    
                    if let habit = associatedHabit {
                        habitCard(habit: habit)
                    }
                    
                    if !goal.milestones.isEmpty {
                        milestonesCard
                    }
                    
                    Spacer()
                }
            }
            .padding(20)
        }
    }
    
    @ViewBuilder
    private var headerCard: some View {
        DetailCard {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(goal.title)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    if !goal.goalDescription.isEmpty {
                        Text(goal.goalDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if goal.isCompleted {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.1))
                        
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.green)
                    }
                    .frame(width: 44, height: 44)
                }
            }
        }
    }
    
    @ViewBuilder
    private var progressCard: some View {
        DetailCard {
            VStack(spacing: 16) {
                HStack {
                    Text("Progreso")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("\(goal.daysRemaining) días")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(6)
                }
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    
                    Circle()
                        .trim(from: 0, to: progressPercentage)
                        .stroke(progressColor, lineWidth: 12)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: progressPercentage)
                    
                    VStack(spacing: 4) {
                        Text("\(Int(progressPercentage * 100))%")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(progressColor)
                        
                        Text("\(actualCount) / \(goal.targetCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 160)
            }
        }
    }
    
    @ViewBuilder
    private var dateInfoCard: some View {
        DetailCard {
            VStack(spacing: 14) {
                InfoRow(
                    icon: "calendar",
                    iconColor: .blue,
                    title: "Fecha Inicio",
                    value: goal.startDate.formatted(date: .abbreviated, time: .omitted)
                )
                
                Divider()
                
                InfoRow(
                    icon: "target",
                    iconColor: .orange,
                    title: "Fecha Límite",
                    value: goal.targetDate.formatted(date: .abbreviated, time: .omitted)
                )
            }
        }
    }
    
    @ViewBuilder
    private func habitCard(habit: Habit) -> some View {
        DetailCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .font(.subheadline)
                        .foregroundColor(.purple)
                    
                    Text("Hábito Asociado")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(habit.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                            
                            Text("\(habit.doneDates.count) completados")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    circularProgressView(
                        value: min(Double(habit.doneDates.count) / Double(goal.targetCount), 1.0),
                        color: .purple
                    )
                }
                .padding(12)
                .background(Color.purple.opacity(0.06))
                .cornerRadius(10)
            }
        }
    }
    
    @ViewBuilder
    private var milestonesCard: some View {
        DetailCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "flag.fill")
                            .font(.subheadline)
                            .foregroundColor(.red)
                        
                        Text("Hitos")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    Text("\(goal.milestones.filter { $0.isCompleted }.count)/\(goal.milestones.count)")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 8) {
                    ForEach(goal.milestones) { milestone in
                        MilestoneRowView(milestone: milestone)
                    }
                }
            }
        }
    }
    
    private func circularProgressView(value: Double, color: Color) -> some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 3)
            
            Circle()
                .trim(from: 0, to: value)
                .stroke(color, lineWidth: 3)
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 50, height: 50)
    }
    
    private func loadAssociatedHabit() {
        guard let habitId = goal.habitId else {
            associatedHabit = nil
            return
        }
        
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate<Habit> { habit in
                habit.id == habitId
            }
        )
        
        do {
            associatedHabit = try modelContext.fetch(descriptor).first
        } catch {
            associatedHabit = nil
        }
    }
    
    private func startAutoRefresh() {
        timer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                refreshTrigger = UUID()
                loadAssociatedHabit()
            }
    }
    
    private var actualCount: Int {
        associatedHabit?.doneDates.count ?? goal.currentCount
    }
    
    private var progressPercentage: Double {
        guard goal.targetCount > 0 else { return 0 }
        return Double(actualCount) / Double(goal.targetCount)
    }
    
    private var progressColor: Color {
        if goal.isCompleted {
            return .green
        } else if progressPercentage > 0.7 {
            return .orange
        } else if progressPercentage > 0.3 {
            return .blue
        }
        return .gray
    }
}

// MARK: - Componentes Reutilizables
struct DetailCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
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

struct InfoRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28)
                .background(iconColor.opacity(0.1))
                .cornerRadius(6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
    }
}

struct MilestoneRowView: View {
    let milestone: Milestone
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(milestone.isCompleted ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                
                Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.caption)
                    .foregroundColor(milestone.isCompleted ? .green : .gray)
            }
            .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(milestone.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 4) {
                    Image(systemName: "target")
                        .font(.caption2)
                    
                    Text("Meta: \(milestone.targetValue)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if milestone.isCompleted, let completedDate = milestone.completedDate {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Listo")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                    
                    Text(completedDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(10)
        .background(milestone.isCompleted ? Color.green.opacity(0.05) : Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}
