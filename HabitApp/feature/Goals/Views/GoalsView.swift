import SwiftUI
import SwiftData

struct GoalsView: View {
    @Query private var goals: [Goal]
    @Query private var habits: [Habit]
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appConfig: AppConfig
    @StateObject private var viewModel: GoalsViewModel
    @State private var showingAddGoal = false
    
    init() {
        _viewModel = StateObject(wrappedValue: GoalsViewModel(storageProvider: AppConfig().storageProvider))
    }
    
    var body: some View {
        #if os(iOS)
        iosBody
        #else
        macBody
        #endif
    }
    
    private func getAssociatedHabit(for goal: Goal) -> Habit? {
        guard let habitId = goal.habitId else { return nil }
        return habits.first { $0.id == habitId }
    }
}

// MARK: - iOS UI
#if os(iOS)
extension GoalsView {
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
                        if !viewModel.getActiveGoals(goals).isEmpty {
                            GoalSection(
                                title: "Objetivos Activos",
                                icon: "flame.fill",
                                goals: viewModel.getActiveGoals(goals),
                                habits: habits,
                                isActive: true
                            )
                        }
                        
                        if !viewModel.getCompletedGoals(goals).isEmpty {
                            GoalSection(
                                title: "Objetivos Completados",
                                icon: "checkmark.seal.fill",
                                goals: viewModel.getCompletedGoals(goals),
                                habits: habits,
                                isActive: false
                            )
                        }
                        
                        if goals.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "target")
                                    .font(.system(size: 48))
                                    .foregroundColor(.blue.opacity(0.5))
                                
                                Text("Sin Objetivos")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text("Crea tu primer objetivo para comenzar a alcanzar tus metas")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                            .padding(.top, 80)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Objetivos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddGoal = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView(habits: habits)
            }
        }
    }
}
#endif

// MARK: - macOS UI
#if os(macOS)
extension GoalsView {
    var macBody: some View {
        NavigationStack {
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
                
                ScrollView {
                    VStack(spacing: 32) {
                        if goals.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "target")
                                    .font(.system(size: 64))
                                    .foregroundColor(.blue.opacity(0.5))
                                
                                Text("Sin Objetivos")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                
                                Text("Crea tu primer objetivo para comenzar a alcanzar tus metas")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(60)
                        } else {
                            VStack(alignment: .leading, spacing: 32) {
                                if !viewModel.getActiveGoals(goals).isEmpty {
                                    VStack(alignment: .leading, spacing: 16) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "flame.fill")
                                                .font(.title3)
                                                .foregroundColor(.orange)
                                            Text("Objetivos Activos")
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                        }
                                        
                                        LazyVGrid(columns: [
                                            GridItem(.adaptive(minimum: 300), spacing: 20)
                                        ], spacing: 20) {
                                            ForEach(viewModel.getActiveGoals(goals)) { goal in
                                                NavigationLink {
                                                    GoalDetailView(goal: goal)
                                                } label: {
                                                    MacGoalCard(goal: goal, habit: getAssociatedHabit(for: goal), isActive: true)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                    }
                                }
                                
                                if !viewModel.getCompletedGoals(goals).isEmpty {
                                    VStack(alignment: .leading, spacing: 16) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "checkmark.seal.fill")
                                                .font(.title3)
                                                .foregroundColor(.green)
                                            Text("Objetivos Completados")
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                        }
                                        
                                        LazyVGrid(columns: [
                                            GridItem(.adaptive(minimum: 300), spacing: 20)
                                        ], spacing: 20) {
                                            ForEach(viewModel.getCompletedGoals(goals)) { goal in
                                                NavigationLink {
                                                    GoalDetailView(goal: goal)
                                                } label: {
                                                    MacGoalCard(goal: goal, habit: getAssociatedHabit(for: goal), isActive: false)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(32)
                        }
                    }
                }
            }
            .navigationTitle("Objetivos")
            .toolbar {
                ToolbarItem {
                    Button {
                        showingAddGoal = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView(habits: habits)
            }
            .frame(minWidth: 800, minHeight: 600)
        }
    }
}

struct MacGoalCard: View {
    let goal: Goal
    let habit: Habit?
    let isActive: Bool
    
    private var actualCount: Int {
        habit?.doneDates.count ?? goal.currentCount
    }
    
    private var actualProgress: Double {
        guard goal.targetCount > 0 else { return 0 }
        return Double(actualCount) / Double(goal.targetCount)
    }
    
    private var progressColor: Color {
        if goal.isCompleted {
            return .green
        } else if actualProgress > 0.7 {
            return .orange
        } else if actualProgress > 0.3 {
            return .blue
        }
        return .gray
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(goal.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    if !goal.goalDescription.isEmpty {
                        Text(goal.goalDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
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
                    .frame(width: 32, height: 32)
                }
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("\(actualCount)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(progressColor)
                    
                    Text("de \(goal.targetCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(actualProgress * 100))%")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(progressColor)
                }
                
                ProgressView(value: actualProgress)
                    .tint(progressColor)
            }
            
            if isActive {
                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("\(goal.daysRemaining) días restantes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if goal.daysRemaining <= 3 {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
                .padding(8)
                .background(Color.yellow.opacity(0.08))
                .cornerRadius(6)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(progressColor.opacity(0.2), lineWidth: 1)
        )
    }
}

#endif

struct GoalSection: View {
    let title: String
    let icon: String
    let goals: [Goal]
    let habits: [Habit]
    let isActive: Bool
    
    private func getAssociatedHabit(for goal: Goal) -> Habit? {
        guard let habitId = goal.habitId else { return nil }
        return habits.first { $0.id == habitId }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isActive ? .orange : .green)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(goals.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)
            }
            .padding(.horizontal, 16)
            
            LazyVStack(spacing: 12) {
                ForEach(goals) { goal in
                    NavigationLink {
                        GoalDetailView(goal: goal)
                    } label: {
                        GoalRowView(goal: goal, habit: getAssociatedHabit(for: goal), isActive: isActive)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct GoalRowView: View {
    let goal: Goal
    let habit: Habit?
    let isActive: Bool
    
    private var actualCount: Int {
        habit?.doneDates.count ?? goal.currentCount
    }
    
    private var actualProgress: Double {
        guard goal.targetCount > 0 else { return 0 }
        return Double(actualCount) / Double(goal.targetCount)
    }
    
    private var progressColor: Color {
        if goal.isCompleted {
            return .green
        } else if actualProgress > 0.7 {
            return .orange
        } else if actualProgress > 0.3 {
            return .blue
        }
        return .gray
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if !goal.goalDescription.isEmpty {
                        Text(goal.goalDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                if goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
            }
            
            HStack(spacing: 8) {
                ProgressView(value: actualProgress)
                    .tint(progressColor)
                
                Text("\(Int(actualProgress * 100))%")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(progressColor)
                    .frame(width: 35)
            }
            
            HStack(spacing: 12) {
                Text("\(actualCount) / \(goal.targetCount)")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if isActive {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text("\(goal.daysRemaining) días")
                            .font(.caption.weight(.medium))
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
                .stroke(progressColor.opacity(0.2), lineWidth: 1)
        )
    }
}

