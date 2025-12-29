import SwiftUI
import SwiftData

struct GoalDetailView: View {
    @Bindable var goal: Goal
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = GoalsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress Card
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "target")
                            .foregroundColor(goal.isCompleted ? .green : .blue)
                            .font(.title)
                        Text(goal.isCompleted ? "¡Completado!" : "En Progreso")
                            .font(.headline)
                    }
                    
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                        
                        Circle()
                            .trim(from: 0, to: goal.progress)
                            .stroke(goal.isCompleted ? Color.green : Color.blue, lineWidth: 20)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut, value: goal.progress)
                        
                        VStack {
                            Text("\(Int(goal.progress * 100))%")
                                .font(.system(size: 36, weight: .bold))
                            Text("\(goal.currentCount) / \(goal.targetCount)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(width: 150, height: 150)
                    
                    if !goal.isCompleted {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                            Text("\(goal.daysRemaining) días restantes")
                                .font(.subheadline)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // Description
                if !goal.goalDescription.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Descripción")
                            .font(.headline)
                        Text(goal.goalDescription)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Milestones
                if !goal.milestones.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Hitos")
                            .font(.headline)
                        
                        ForEach(goal.milestones.sorted { $0.targetValue < $1.targetValue }) { milestone in
                            MilestoneRowView(milestone: milestone, currentCount: goal.currentCount)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Associated Habit
                if let habit = goal.habit {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hábito Asociado")
                            .font(.headline)
                        
                        HStack {
                            Text(habit.title)
                                .font(.body)
                            Spacer()
                            Text("\(habit.doneDates.count) días completados")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Button("Actualizar Progreso") {
                            viewModel.updateGoalProgress(goal, habit: habit)
                            viewModel.checkMilestones(goal)
                            try? modelContext.save()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Información")
                        .font(.headline)
                    
                    HStack {
                        Text("Fecha de inicio:")
                        Spacer()
                        Text(goal.startDate, format: .dateTime.day().month().year())
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Fecha límite:")
                        Spacer()
                        Text(goal.targetDate, format: .dateTime.day().month().year())
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle(goal.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    viewModel.deleteGoal(goal, context: modelContext)
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
    }
}

struct MilestoneRowView: View {
    let milestone: Milestone
    let currentCount: Int
    
    var body: some View {
        HStack {
            Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(milestone.isCompleted ? .green : .gray)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(milestone.title)
                    .font(.body)
                    .strikethrough(milestone.isCompleted)
                
                Text("\(milestone.targetValue) días")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if milestone.isCompleted, let date = milestone.completedDate {
                Text(date, format: .dateTime.day().month())
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}
