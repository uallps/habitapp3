//
//  Untitled.swift
//  HabitApp
//
//  Created by Aula03 on 5/11/25.
//

import SwiftUI

struct Category: Identifiable {
    let id: UUID
    var name: String
    var color: Color
    var icon : Icon
    var priority : Priority
    var frequency : Frequency
    var progress : Progress


    init(
        id: UUID = UUID(),
        name: String,
        color: Color = .blue,
        icon: Icon,
        priority: Priority,
        frequency: Frequency,
        progress: Progress
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
        self.priority = priority
        self.frequency = frequency
        self.progress = progress
    }
}

