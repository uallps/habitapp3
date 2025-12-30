import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingAbout = false
    @State private var showingClearAlert = false
    
    var body: some View {
        #if os(iOS)
        iosBody
        #else
        macBody
        #endif
    }
}

// MARK: - iOS UI
#if os(iOS)
extension SettingsView {
    var iosBody: some View {
        NavigationStack {
            List {
                Section("Visualización") {
                    Toggle("Mostrar fechas de vencimiento", isOn: Binding(
                        get: { AppConfig.showDueDates },
                        set: { AppConfig.showDueDates = $0 }
                    ))
                    Toggle("Mostrar prioridades", isOn: Binding(
                        get: { AppConfig.showPriorities },
                        set: { AppConfig.showPriorities = $0 }
                    ))
                }
                
                Section("Notificaciones") {
                    NavigationLink("Configurar recordatorios") {
                        NotificationSettingsView()
                    }
                }
                
                Section("Datos") {
                    Button("Limpiar todos los datos", role: .destructive) {
                        showingClearAlert = true
                    }
                }
                
                Section("Información") {
                    Button("Acerca de HabitApp") {
                        showingAbout = true
                    }
                    
                    HStack {
                        Text("Versión")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Ajustes")
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .alert("Limpiar todos los datos", isPresented: $showingClearAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Limpiar", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("Esta acción eliminará todos los hábitos, notas y objetivos. No se puede deshacer.")
            }
        }
    }
}
#endif

// MARK: - macOS UI
#if os(macOS)
extension SettingsView {
    var macBody: some View {
        VStack(spacing: 20) {
            Form {
                Section("Visualización") {
                    Toggle("Mostrar fechas de vencimiento", isOn: Binding(
                        get: { AppConfig.showDueDates },
                        set: { AppConfig.showDueDates = $0 }
                    ))
                    Toggle("Mostrar prioridades", isOn: Binding(
                        get: { AppConfig.showPriorities },
                        set: { AppConfig.showPriorities = $0 }
                    ))
                }
                
                Section("Notificaciones") {
                    Button("Configurar recordatorios") {
                        // Abrir ventana de configuración
                    }
                }
                
                Section("Datos") {
                    Button("Limpiar todos los datos") {
                        showingClearAlert = true
                    }
                    .foregroundColor(.red)
                }
                
                Section("Información") {
                    HStack {
                        Text("Versión 1.0.0")
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("Acerca de") {
                            showingAbout = true
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Ajustes")
        .frame(minWidth: 400, minHeight: 300)
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .alert("Limpiar todos los datos", isPresented: $showingClearAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Limpiar", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("Esta acción eliminará todos los hábitos, notas y objetivos. No se puede deshacer.")
        }
    }
}
#endif

// MARK: - Functions
extension SettingsView {
    private func clearAllData() {
        do {
            // Eliminar todos los hábitos
            try modelContext.delete(model: Habit.self)
            
            // Eliminar todas las notas
            try modelContext.delete(model: DailyNote.self)
            
            // Eliminar todos los objetivos
            try modelContext.delete(model: Goal.self)
            
            try modelContext.save()
        } catch {
            print("Error clearing data: \(error)")
        }
    }
}
