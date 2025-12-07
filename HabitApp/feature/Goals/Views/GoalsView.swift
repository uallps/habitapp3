import SwiftUI
import SwiftData

struct GoalsView: View {
    @Query private var goals: [Goal]
    @Query private var habits: [Habit]
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = GoalsViewModel()
    @State private var showingAddGoal = false
    
    var body: some View {
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
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}