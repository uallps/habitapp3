import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
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
extension AboutView {
    var iosBody: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("HabitApp")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Versión 1.0.0")
                    .foregroundColor(.secondary)
                
                Text("Una aplicación para gestionar tus hábitos diarios y alcanzar tus objetivos.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 8) {
                    Text("Desarrollado con SwiftUI")
                    Text("Compatible con iOS y macOS")
                    Text("Sistema de notificaciones inteligentes")
                    Text("Arquitectura MVVM")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Acerca de")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
#endif

// MARK: - macOS UI
#if os(macOS)
extension AboutView {
    var macBody: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("HabitApp")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Versión 1.0.0")
                .foregroundColor(.secondary)
            
            Text("Una aplicación para gestionar tus hábitos diarios y alcanzar tus objetivos.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 6) {
                Text("Desarrollado con SwiftUI")
                Text("Compatible con iOS y macOS")
                Text("Sistema de notificaciones inteligentes")
                Text("Arquitectura MVVM")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Button("Cerrar") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding(.top)
        }
        .padding()
        .frame(minWidth: 350, minHeight: 300)
    }
}
#endif