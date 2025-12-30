//
//  StreakBadgeView.swift
//  HabitApp
//
//  Created by Aula03 on 30/12/25.
//


import SwiftUI

struct StreakBadgeView: View {
    let count: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundColor(count > 0 ? .orange : .gray)
            
            Text("\(count)")
                .font(.caption)
                .fontWeight(.bold)
                .monospacedDigit()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(count > 0 ? Color.orange.opacity(0.2) : Color.gray.opacity(0.1))
        )
    }
}

#Preview {
    VStack {
        StreakBadgeView(count: 5)
        StreakBadgeView(count: 0)
    }
}