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
#if os(ios)
        Section("Recordatorios") {
            Toggle("Activar recordatorio", isOn: $isEnabled)
            
            if isEnabled {
                DatePicker("Hora", selection: $time, displayedComponents: .hourAndMinute)
            }
        }
        #endif
    
#if os(mac)
        VStack(alignment: .leading, spacing: 10) {
                    Toggle("Activar recordatorio", isOn: $isEnabled)
                        .toggleStyle(.switch)
                    
                    if isEnabled {
                        DatePicker("Seleccionar hora", selection: $time, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.stepperField)
                            .controlSize(.large)
                            .labelsHidden()
                    }
                }
#endif
    }
}




