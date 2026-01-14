//
//  AchievementRowView.swift
//  HabitApp
//
//  Created by Juanjo Fernández Requena on 13/1/26.
//

import SwiftUI

struct AchievementRowView: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 10) {
            // Icono
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 38, height: 38)
                
                Image(systemName: achievement.iconName)
                    .font(.callout)
                    .foregroundColor(achievement.isUnlocked ? .blue : .gray)
            }
            
            // Texto
            VStack(alignment: .leading, spacing: 3) {
                Text(achievement.title)
                    .font(.subheadline)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                
                Text(achievement.achievementDescription)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                
                if achievement.isUnlocked, let unlockedDate = achievement.unlockedAt {
                    Text("Desbloqueado: \(unlockedDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            // Estado
            Image(systemName: achievement.isUnlocked ? "checkmark.circle.fill" : "lock.fill")
                .foregroundColor(achievement.isUnlocked ? .green : .gray)
                .font(.body)
        }
        .padding(.vertical, 6)
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}

