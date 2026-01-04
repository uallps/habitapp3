//
//  RecordatorioView.swift
//  HabitApp
//
//  Created by Aula03 on 3/12/25.
//

import SwiftUI
import SwiftData

struct RecordatorioView: View {
    @Binding var isEnabled: Bool
        @Binding var time: Date
        
        var body: some View {
            Section("Recordatorios") {
                Toggle("Activar recordatorio", isOn: $isEnabled)
                
                if isEnabled {
                    DatePicker("Hora", selection: $time, displayedComponents: .hourAndMinute)
                }
            }
        }
}
