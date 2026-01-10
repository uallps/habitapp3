import SwiftUI
import SwiftData
import Combine

struct GoalDetailView: View {
    @Bindable var goal: Goal
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: GoalsViewModel
    @State private var associatedHabit: Habit?
    @State private var refreshTrigger = UUID()
    @State private var timer: AnyCancellable?
    
    init(goal: Goal, storageProvider: StorageProvider) {
        self._goal = Bindable(goal)
        _viewModel = StateObject(wrappedValue: GoalsViewModel(storageProvider: storageProvider))
    }
    
    var body: some View {
        #if os(iOS)
        iosBody
        #else
        macBody
        #endif
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

// MARK: - iOS UI
#if os(iOS)
extension GoalDetailView {
    var iosBody: some View {
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
                VStack(spacing: 20) {
                    //  Header con Progreso Circular
                    VStack(spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(goal.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                if !goal.goalDescription.isEmpty {
                                    Text(goal.goalDescription)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if goal.isCompleted {
                                ZStack {
                                    Circle()
                                        .fill(Color.green.opacity(0.1))
                                    
                                    Image(systemName: "checkmark")
                                        .font(.title3.weight(.semibold))
                                        .foregroundColor(.green)
                                }
                                .frame(width: 50, height: 50)
                            }
                        }
                        
                        // Progreso circular
                        VStack(spacing: 16) {
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
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(progressColor)
                                    
                                    Text("\(actualCount) de \(goal.targetCount)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(height: 150)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                    
                    //  Información de Fechas
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "calendar")
                                .font(.title3)
                                .foregroundColor(.blue)
                                .frame(width: 32, height: 32)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Fecha de Inicio")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(goal.startDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                        }
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "target")
                                .font(.title3)
                                .foregroundColor(.orange)
                                .frame(width: 32, height: 32)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Fecha Objetivo")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(goal.targetDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Días Restantes")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: goal.daysRemaining <= 3 ? "exclamationmark.circle.fill" : "checkmark.circle")
                                        .foregroundColor(goal.daysRemaining <= 3 ? .orange : .green)
                                    
                                    Text("\(goal.daysRemaining)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    //  Hábito Asociado
                    if let habit = associatedHabit {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "bolt.fill")
                                    .font(.title3)
                                    .foregroundColor(.purple)
                                
                                Text("Hábito Asociado")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(habit.title)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                    
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                        
                                        Text("\(habit.doneDates.count) días completados")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .center, spacing: 4) {
                                    ZStack {
                                        Circle()
                                            .stroke(Color.purple.opacity(0.2), lineWidth: 3)
                                        
                                        Circle()
                                            .trim(from: 0, to: min(Double(habit.doneDates.count) / Double(goal.targetCount), 1.0))
                                            .stroke(Color.purple, lineWidth: 3)
                                            .rotationEffect(.degrees(-90))
                                    }
                                    .frame(width: 50, height: 50)
                                    
                                    Text("\(habit.doneDates.count)")
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(.purple)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.purple.opacity(0.08))
                                    .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    //  Milestones
                    if !goal.milestones.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "flag.fill")
                                    .font(.title3)
                                    .foregroundColor(.red)
                                
                                Text("Hitos")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
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
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding(16)
            }
        }
        .navigationTitle(goal.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadAssociatedHabit()
            startAutoRefresh()
        }
        .onDisappear {
            timer?.cancel()
        }
        .id(refreshTrigger)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
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
        }
    }
}
#endif

// MARK: - macOS UI
#if os(macOS)
extension GoalDetailView {
    var macBody: some View {
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
                HStack(alignment: .top, spacing: 24) {
                    // Left Column
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(goal.title)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    if !goal.goalDescription.isEmpty {
                                        Text(goal.goalDescription)
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                if goal.isCompleted {
                                    ZStack {
                                        Circle()
                                            .fill(Color.green.opacity(0.1))
                                        
                                        Image(systemName: "checkmark")
                                            .font(.title3.weight(.semibold))
                                            .foregroundColor(.green)
                                    }
                                    .frame(width: 50, height: 50)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Información")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "calendar")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                    .frame(width: 32, height: 32)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Inicio")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(goal.startDate.formatted(date: .abbreviated, time: .omitted))
                                        .font(.body)
                                        .fontWeight(.medium)
                                }
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 12) {
                                Image(systemName: "target")
                                    .font(.title3)
                                    .foregroundColor(.orange)
                                    .frame(width: 32, height: 32)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Objetivo")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(goal.targetDate.formatted(date: .abbreviated, time: .omitted))
                                        .font(.body)
                                        .fontWeight(.medium)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(12)
                        
                        Spacer()
                    }
                    .frame(maxWidth: 280)
                    
                    // Right Column
                    VStack(alignment: .leading, spacing: 16) {
                        // Progreso Circular
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
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                                
                                Circle()
                                    .trim(from: 0, to: progressPercentage)
                                    .stroke(progressColor, lineWidth: 10)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut(duration: 0.5), value: progressPercentage)
                                
                                VStack(spacing: 4) {
                                    Text("\(Int(progressPercentage * 100))%")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(progressColor)
                                    
                                    Text("\(actualCount) de \(goal.targetCount)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(height: 140)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.controlBackgroundColor))
                        )
                        
                        // Hábito Asociado
                        if let habit = associatedHabit {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 8) {
                                    Image(systemName: "bolt.fill")
                                        .font(.title3)
                                        .foregroundColor(.purple)
                                    
                                    Text("Hábito Asociado")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(habit.title)
                                            .font(.body)
                                            .fontWeight(.semibold)
                                        
                                        HStack(spacing: 4) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                                .font(.caption)
                                            
                                            Text("\(habit.doneDates.count) completados")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    ZStack {
                                        Circle()
                                            .stroke(Color.purple.opacity(0.2), lineWidth: 3)
                                        
                                        Circle()
                                            .trim(from: 0, to: min(Double(habit.doneDates.count) / Double(goal.targetCount), 1.0))
                                            .stroke(Color.purple, lineWidth: 3)
                                            .rotationEffect(.degrees(-90))
                                    }
                                    .frame(width: 50, height: 50)
                                }
                                .padding()
                                .background(Color.purple.opacity(0.08))
                                .cornerRadius(12)
                            }
                            .padding()
                            .background(Color(.controlBackgroundColor))
                            .cornerRadius(12)
                        }
                        
                        // Milestones
                        if !goal.milestones.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    HStack(spacing: 8) {
                                        Image(systemName: "flag.fill")
                                            .font(.title3)
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
                                        MacMilestoneRow(milestone: milestone)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.controlBackgroundColor))
                            .cornerRadius(12)
                        }
                        
                        Spacer()
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle(goal.title)
        .onAppear {
            loadAssociatedHabit()
            startAutoRefresh()
        }
        .onDisappear {
            timer?.cancel()
        }
        .id(refreshTrigger)
        .toolbar {
            ToolbarItem {
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
        }
        .frame(minWidth: 700, minHeight: 500)
    }
}
#endif

struct MilestoneRowView: View {
    let milestone: Milestone
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(milestone.isCompleted ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                
                Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(milestone.isCompleted ? .green : .gray)
            }
            .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(milestone.title)
                    .fontWeight(.semibold)
                
                HStack(spacing: 4) {
                    Image(systemName: "target")
                        .font(.caption2)
                    
                    Text("Meta: \(milestone.targetValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if milestone.isCompleted, let completedDate = milestone.completedDate {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Completado")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Text(completedDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.green)
                }
            }
        }
        .padding(12)
        .background(milestone.isCompleted ? Color.green.opacity(0.05) : Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

#if os(macOS)
struct MacMilestoneRow: View {
    let milestone: Milestone
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(milestone.isCompleted ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                
                Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(milestone.isCompleted ? .green : .gray)
            }
            .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(milestone.title)
                    .fontWeight(.semibold)
                
                HStack(spacing: 4) {
                    Image(systemName: "target")
                        .font(.caption2)
                    
                    Text("Meta: \(milestone.targetValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if milestone.isCompleted, let completedDate = milestone.completedDate {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Completado")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Text(completedDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.green)
                }
            }
        }
        .padding(12)
        .background(milestone.isCompleted ? Color.green.opacity(0.05) : Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}
#endif
