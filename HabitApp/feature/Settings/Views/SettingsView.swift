import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appConfig: AppConfig
    @State private var showingAbout = false
    
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
                    Toggle("Mostrar fechas de vencimiento", isOn: $appConfig.showDueDates)
                    Toggle("Mostrar prioridades", isOn: $appConfig.showPriorities)
                }
                
                Section("Notificaciones") {
                    NavigationLink("Configurar recordatorios") {
                        NotificationSettingsView()
                    }
                }
                
                Section("Datos") {
                    Button("Exportar datos") {
                        exportData()
                    }
                    
                    Button("Importar datos") {
                        importData()
                    }
                    
                    Button("Limpiar todos los datos", role: .destructive) {
                        clearAllData()
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
                    Toggle("Mostrar fechas de vencimiento", isOn: $appConfig.showDueDates)
                    Toggle("Mostrar prioridades", isOn: $appConfig.showPriorities)
                }
                
                Section("Notificaciones") {
                    Button("Configurar recordatorios") {
                        // Abrir ventana de configuración
                    }
                }
                
                Section("Datos") {
                    HStack {
                        Button("Exportar datos") {
                            exportData()
                        }
                        
                        Button("Importar datos") {
                            importData()
                        }
                        
                        Button("Limpiar datos") {
                            clearAllData()
                        }
                        .foregroundColor(.red)
                    }
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
    }
}
#endif

// MARK: - Functions
extension SettingsView {
    private func exportData() {
        // TODO: Implementar exportación de datos
        print("Exportando datos...")
    }
    
    private func importData() {
        // TODO: Implementar importación de datos
        print("Importando datos...")
    }
    
    private func clearAllData() {
        // TODO: Implementar limpieza de datos
        print("Limpiando datos...")
    }
}