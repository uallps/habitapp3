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
        // Inicializar el viewModel con storageProvider
        _viewModel = StateObject(wrappedValue: GoalsViewModel(storageProvider: AppConfig().storageProvider))
    }
    
    var body: some View {
        #if os(iOS)
        iosBody
        #else
        macBody
        #endif
    }
}

// MARK: - iOS UI
#if os(iOS)
extension GoalsView {
    var iosBody: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if !viewModel.getActiveGoals(goals).isEmpty {
                        GoalSection(
                            title: "Objetivos Activos",
                            goals: viewModel.getActiveGoals(goals),
                            isActive: true
                        )
                    }
                    
                    if !viewModel.getCompletedGoals(goals).isEmpty {
                        GoalSection(
                            title: "Objetivos Completados",
                            goals: viewModel.getCompletedGoals(goals),
                            isActive: false
                        )
                    }
                    
                    if goals.isEmpty {
                        ContentUnavailableView(
                            "Sin Objetivos",
                            systemImage: "target",
                            description: Text("Crea tu primer objetivo para comenzar")
                        )
                        .padding(.top, 100)
                    }
                }
                .padding()
            }
            .navigationTitle("Objetivos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddGoal = true
                    } label: {
                        Image(systemName: "plus")
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
            ScrollView {
                VStack(spacing: 20) {
                    if goals.isEmpty {
                        ContentUnavailableView(
                            "Sin Objetivos",
                            systemImage: "target",
                            description: Text("Crea tu primer objetivo para comenzar")
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        VStack(alignment: .leading, spacing: 20) {
                            if !viewModel.getActiveGoals(goals).isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Objetivos Activos")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    
                                    LazyVGrid(columns: [
                                        GridItem(.flexible(), spacing: 16),
                                        GridItem(.flexible(), spacing: 16)
                                    ], spacing: 16) {
                                        ForEach(viewModel.getActiveGoals(goals)) { goal in
                                            NavigationLink {
                                                GoalDetailView(goal: goal)
                                            } label: {
                                                MacGoalCard(goal: goal, isActive: true)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                            
                            if !viewModel.getCompletedGoals(goals).isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Objetivos Completados")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    
                                    LazyVGrid(columns: [
                                        GridItem(.flexible(), spacing: 16),
                                        GridItem(.flexible(), spacing: 16)
                                    ], spacing: 16) {
                                        ForEach(viewModel.getCompletedGoals(goals)) { goal in
                                            NavigationLink {
                                                GoalDetailView(goal: goal)
                                            } label: {
                                                MacGoalCard(goal: goal, isActive: false)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Objetivos")
            .toolbar {
                ToolbarItem {
                    Button {
                        showingAddGoal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView(habits: habits)
            }
            .frame(minWidth: 600, minHeight: 400)
        }
    }
}

struct MacGoalCard: View {
    let goal: Goal
    let isActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if !goal.goalDescription.isEmpty {
                        Text(goal.goalDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                if goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            
            // Progress circle
            HStack {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                    
                    Circle()
                        .trim(from: 0, to: goal.progress)
                        .stroke(goal.isCompleted ? Color.green : Color.blue, lineWidth: 4)
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(Int(goal.progress * 100))%")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("\(goal.currentCount) / \(goal.targetCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            if isActive {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text("\(goal.daysRemaining) días restantes")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#endif

struct GoalSection: View {
    let title: String
    let goals: [Goal]
    let isActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            LazyVStack(spacing: 12) {
                ForEach(goals) { goal in
                    NavigationLink {
                        GoalDetailView(goal: goal)
                    } label: {
                        GoalRowView(goal: goal, isActive: isActive)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct GoalRowView: View {
    let goal: Goal
    let isActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                    
                    if !goal.goalDescription.isEmpty {
                        Text(goal.goalDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                if goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            
            ProgressView(value: goal.progress)
                .tint(goal.isCompleted ? .green : .blue)
            
            HStack {
                Text("\(goal.currentCount) / \(goal.targetCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if isActive {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text("\(goal.daysRemaining) días")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

