//
//  TestReminderView.swift
//  HabitApp
//
//  Created by Aula03 on 22/11/25.
//

import SwiftUI
import SwiftData
import UserNotifications


struct TestReminderView: View {
    @StateObject private var viewModel: DailyNotesViewModel

    init() {
        // Creamos un contexto temporal para pruebas
        let context = ModelContext(try! ModelContainer(for: DailyNote.self))
        _viewModel = StateObject(wrappedValue: DailyNotesViewModel(modelContext: context))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Prueba de ReminderPlugin")
                .font(.title2)
                .padding()
            
            Button("Crear nota con notificación en 10s") {
                let futureDate = Date().addingTimeInterval(10)
                let note = DailyNote(title: "Recordatorio Test", content: "Esta es una prueba", date: futureDate)
                
                viewModel.addNote(title: note.title, content: note.content)
                
                print("Nota creada con fecha: \(futureDate)")
                
                // Listar notificaciones pendientes
                UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                    for r in requests {
                        print("Notificación pendiente: \(r.identifier) - \(r.content.title)")
                    }
                }
            }
        }
        .padding()
    }
}
