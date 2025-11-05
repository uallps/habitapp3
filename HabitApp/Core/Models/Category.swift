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

    init(id: UUID = UUID(), name: String, color: Color = .blue) {
        self.id = id
        self.name = name
        self.color = color
    }
}
