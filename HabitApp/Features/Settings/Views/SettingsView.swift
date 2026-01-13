import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var userPreferences: UserPreferences
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
                        get: { userPreferences.showDueDates },
                        set: { userPreferences.showDueDates = $0 }
                    ))
                    Toggle("Mostrar prioridades", isOn: Binding(
                        get: { userPreferences.showPriorities },
                        set: { userPreferences.showPriorities = $0 }
                    ))
                }
                
                Section("Características") {
                    Toggle("Notas diarias", isOn: Binding(
                        get: { userPreferences.enableDailyNotes },
                        set: { userPreferences.enableDailyNotes = $0 }
                    ))
                    Toggle("Objetivos", isOn: Binding(
                        get: { userPreferences.enableGoals },
                        set: { userPreferences.enableGoals = $0 }
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
                
                Section("Plugins y Personalización") {
                    ForEach(0..<PluginRegistry.shared.getPluginSettingsViews().count, id: \.self) { index in
                        PluginRegistry.shared.getPluginSettingsViews()[index]
                    }
                }            }
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
                        get: { userPreferences.showDueDates },
                        set: { userPreferences.showDueDates = $0 }
                    ))
                    Toggle("Mostrar prioridades", isOn: Binding(
                        get: { userPreferences.showPriorities },
                        set: { userPreferences.showPriorities = $0 }
                    ))
                }
                
                Section("Características") {
                    Toggle("Notas diarias", isOn: Binding(
                        get: { userPreferences.enableDailyNotes },
                        set: { userPreferences.enableDailyNotes = $0 }
                    ))
                    Toggle("Objetivos", isOn: Binding(
                        get: { userPreferences.enableGoals },
                        set: { userPreferences.enableGoals = $0 }
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
            let habitDescriptor = FetchDescriptor<Habit>()
            let habits = try modelContext.fetch(habitDescriptor)
            habits.forEach { modelContext.delete($0) }
            
            // Eliminar todas las notas
            let noteDescriptor = FetchDescriptor<DailyNote>()
            let notes = try modelContext.fetch(noteDescriptor)
            notes.forEach { modelContext.delete($0) }
            
            // Eliminar todos los objetivos
            let goalDescriptor = FetchDescriptor<Goal>()
            let goals = try modelContext.fetch(goalDescriptor)
            goals.forEach { modelContext.delete($0) }
            
            // Eliminar todos los milestones
            let milestoneDescriptor = FetchDescriptor<Milestone>()
            let milestones = try modelContext.fetch(milestoneDescriptor)
            milestones.forEach { modelContext.delete($0) }
            
            try modelContext.save()
            
            // Resetear preferencias de usuario a valores por defecto
            userPreferences.showDueDates = true
            userPreferences.showPriorities = true
            userPreferences.enableReminders = true
            userPreferences.enableHabits = true
            userPreferences.enableGoals = true
            userPreferences.enableDailyNotes = true
            userPreferences.appTheme = 0
            
            print("✅ Todos los datos y preferencias han sido limpiados")
        } catch {
            print("❌ Error clearing data: \(error)")
        }
    }
}
