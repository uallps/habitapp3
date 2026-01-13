import SwiftUI
import SwiftData

struct GoalsView: View {
    @Query private var goals: [Goal]
    @Query private var habits: [Habit]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var userPreferences: UserPreferences
    @StateObject private var viewModel: GoalsViewModel
    @State private var showingAddGoal = false
    
    private let storageProvider: StorageProvider
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        _viewModel = StateObject(wrappedValue: GoalsViewModel(storageProvider: storageProvider))
    }
    
    var body: some View {
        NavigationStack {
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
                
                if goals.isEmpty {
                    emptyState
                } else {
                    contentView
                }
            }
            .navigationTitle("Objetivos")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    addButton
                }
                #endif
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView(habits: habits)
            }
        }
    }
    
    private var addButton: some View {
        Button {
            showingAddGoal = true
        } label: {
            Label("Nuevo", systemImage: "plus.circle.fill")
        }
        .foregroundColor(userPreferences.accentColor)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.system(size: isCompact ? 48 : 64))
                .foregroundColor(.blue.opacity(0.5))
            
            Text("Sin Objetivos")
                .font(isCompact ? .title2 : .title)
                .fontWeight(.semibold)
            
            Text("Crea tu primer objetivo para comenzar a alcanzar tus metas")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showingAddGoal = true
            } label: {
                Label("Crear Objetivo", systemImage: "plus.circle.fill")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(userPreferences.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .padding(.top, 80)
    }
    
    @ViewBuilder
    private var contentView: some View {
        if isCompact {
            compactContent
        } else {
            regularContent
        }
    }
    
    private var compactContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                if !viewModel.getActiveGoals(goals).isEmpty {
                    GoalSectionView(
                        title: "Objetivos Activos",
                        icon: "flame.fill",
                        goals: viewModel.getActiveGoals(goals),
                        habits: habits,
                        storageProvider: storageProvider,
                        isActive: true,
                        isCompact: true
                    )
                }
                
                if !viewModel.getCompletedGoals(goals).isEmpty {
                    GoalSectionView(
                        title: "Objetivos Completados",
                        icon: "checkmark.seal.fill",
                        goals: viewModel.getCompletedGoals(goals),
                        habits: habits,
                        storageProvider: storageProvider,
                        isActive: false,
                        isCompact: true
                    )
                }
            }
            .padding(16)
        }
    }
    
    private var regularContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                if !viewModel.getActiveGoals(goals).isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Image(systemName: "flame.fill")
                                .font(.title3)
                                .foregroundColor(userPreferences.accentColor)
                            Text("Objetivos Activos")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 20)], spacing: 20) {
                            ForEach(viewModel.getActiveGoals(goals)) { goal in
                                NavigationLink {
                                    GoalDetailView(goal: goal, storageProvider: storageProvider)
                                } label: {
                                    GoalCardView(
                                        goal: goal,
                                        habit: getAssociatedHabit(for: goal),
                                        isActive: true
                                    )
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
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 20)], spacing: 20) {
                            ForEach(viewModel.getCompletedGoals(goals)) { goal in
                                NavigationLink {
                                    GoalDetailView(goal: goal, storageProvider: storageProvider)
                                } label: {
                                    GoalCardView(
                                        goal: goal,
                                        habit: getAssociatedHabit(for: goal),
                                        isActive: false
                                    )
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
    
    private func getAssociatedHabit(for goal: Goal) -> Habit? {
        guard let habitId = goal.habitId else { return nil }
        return habits.first { $0.id == habitId }
    }
}

// MARK: - Componentes Reutilizables
struct GoalSectionView: View {
    let title: String
    let icon: String
    let goals: [Goal]
    let habits: [Habit]
    let storageProvider: StorageProvider
    let isActive: Bool
    let isCompact: Bool
    
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
                        GoalDetailView(goal: goal, storageProvider: storageProvider)
                    } label: {
                        GoalRowView(
                            goal: goal,
                            habit: getAssociatedHabit(for: goal),
                            isActive: isActive
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct GoalCardView: View {
    let goal: Goal
    let habit: Habit?
    let isActive: Bool
    @EnvironmentObject private var userPreferences: UserPreferences
    
    private var actualCount: Int {
        habit?.doneDates.count ?? goal.currentCount
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                    
                    Text("\(Int(progressPercentage * 100))%")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(progressColor)
                }
                
                ProgressView(value: progressPercentage)
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
                            .foregroundColor(userPreferences.accentColor)
                    }
                }
                .padding(6)
                .background(Color.yellow.opacity(0.08))
                .cornerRadius(4)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                #if os(iOS)
                .fill(Color(.systemGray6))
                #else
                .fill(Color(.controlBackgroundColor))
                #endif
                .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(progressColor.opacity(0.2), lineWidth: 1)
        )
    }
}

struct GoalRowView: View {
    let goal: Goal
    let habit: Habit?
    let isActive: Bool
    
    private var actualCount: Int {
        habit?.doneDates.count ?? goal.currentCount
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
                ProgressView(value: progressPercentage)
                    .tint(progressColor)
                
                Text("\(Int(progressPercentage * 100))%")
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