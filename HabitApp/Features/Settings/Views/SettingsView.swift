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
                    Toggle("Hábitos", isOn: Binding(
                        get: { userPreferences.enableHabits },
                        set: { userPreferences.enableHabits = $0 }
                    ))
                    Toggle("Notas diarias", isOn: Binding(
                        get: { userPreferences.enableDailyNotes },
                        set: { userPreferences.enableDailyNotes = $0 }
                    ))
                    Toggle("Objetivos", isOn: Binding(
                        get: { userPreferences.enableGoals },
                        set: { userPreferences.enableGoals = $0 }
                    ))
                    Toggle("Estadísticas", isOn: Binding(
                        get: { userPreferences.enableStatistics },
                        set: { userPreferences.enableStatistics = $0 }
                    ))
                    Toggle("Rachas", isOn: Binding(
                        get: { userPreferences.enableStreaks },
                        set: { userPreferences.enableStreaks = $0 }
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
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ajustes")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Personaliza tu experiencia con HabitApp")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 32)
                .padding(.top, 24)
                
                Divider()
                
                // Visualización
                SettingsSection(
                    title: "Visualización",
                    icon: "eye.fill",
                    iconColor: .blue
                ) {
                    SettingsRow(
                        title: "Mostrar fechas de vencimiento",
                        description: "Muestra cuándo vence cada hábito"
                    ) {
                        Toggle("", isOn: Binding(
                            get: { userPreferences.showDueDates },
                            set: { userPreferences.showDueDates = $0 }
                        ))
                        .labelsHidden()
                    }
                    
                    Divider()
                        .padding(.leading, 40)
                    
                    SettingsRow(
                        title: "Mostrar prioridades",
                        description: "Visualiza el nivel de importancia de cada hábito"
                    ) {
                        Toggle("", isOn: Binding(
                            get: { userPreferences.showPriorities },
                            set: { userPreferences.showPriorities = $0 }
                        ))
                        .labelsHidden()
                    }
                }
                
                // Características
                SettingsSection(
                    title: "Características",
                    icon: "slider.horizontal.3",
                    iconColor: .purple
                ) {
                    SettingsRow(
                        title: "Hábitos",
                        description: "Activa o desactiva la gestión de hábitos"
                    ) {
                        Toggle("", isOn: Binding(
                            get: { userPreferences.enableHabits },
                            set: { userPreferences.enableHabits = $0 }
                        ))
                        .labelsHidden()
                    }
                    
                    Divider()
                        .padding(.leading, 40)
                    
                    SettingsRow(
                        title: "Notas diarias",
                        description: "Agrega notas y reflexiones a tus hábitos"
                    ) {
                        Toggle("", isOn: Binding(
                            get: { userPreferences.enableDailyNotes },
                            set: { userPreferences.enableDailyNotes = $0 }
                        ))
                        .labelsHidden()
                    }
                    
                    Divider()
                        .padding(.leading, 40)
                    
                    SettingsRow(
                        title: "Objetivos",
                        description: "Establece y sigue metas a largo plazo"
                    ) {
                        Toggle("", isOn: Binding(
                            get: { userPreferences.enableGoals },
                            set: { userPreferences.enableGoals = $0 }
                        ))
                        .labelsHidden()
                    }
                    
                    Divider()
                        .padding(.leading, 40)
                    
                    SettingsRow(
                        title: "Estadísticas",
                        description: "Habilita la vista de estadísticas"
                    ) {
                        Toggle("", isOn: Binding(
                            get: { userPreferences.enableStatistics },
                            set: { userPreferences.enableStatistics = $0 }
                        ))
                        .labelsHidden()
                    }
                    
                    Divider()
                        .padding(.leading, 40)
                    
                    SettingsRow(
                        title: "Rachas",
                        description: "Activa el seguimiento de streaks"
                    ) {
                        Toggle("", isOn: Binding(
                            get: { userPreferences.enableStreaks },
                            set: { userPreferences.enableStreaks = $0 }
                        ))
                        .labelsHidden()
                    }
                }
                
                // Notificaciones
                SettingsSection(
                    title: "Notificaciones",
                    icon: "bell.fill",
                    iconColor: .orange
                ) {
                    SettingsRow(
                        title: "Configurar recordatorios",
                        description: "Gestiona cuándo recibir notificaciones"
                    ) {
                        Button("Configurar") {
                            // Abrir ventana de configuración
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                // Datos
                SettingsSection(
                    title: "Datos",
                    icon: "externaldrive.fill",
                    iconColor: .red
                ) {
                    SettingsRow(
                        title: "Limpiar todos los datos",
                        description: "Elimina todos los hábitos, notas y objetivos permanentemente"
                    ) {
                        Button("Limpiar") {
                            showingClearAlert = true
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                }
                
                // Información
                SettingsSection(
                    title: "Información",
                    icon: "info.circle.fill",
                    iconColor: .green
                ) {
                    SettingsRow(
                        title: "Versión",
                        description: "HabitApp 1.0.0"
                    ) {
                        Button("Acerca de") {
                            showingAbout = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minWidth: 600, idealWidth: 700, minHeight: 500)
        .background(Color(.windowBackgroundColor))
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

// MARK: - macOS Components
struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
                    .frame(width: 24)
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 32)
            
            VStack(alignment: .leading, spacing: 0) {
                content
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(10)
            .padding(.horizontal, 32)
        }
    }
}

struct SettingsRow<Content: View>: View {
    let title: String
    let description: String
    @ViewBuilder let content: Content
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            content
        }
        .padding(.vertical, 8)
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