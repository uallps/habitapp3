import SwiftUI

extension View {
    func dailyNotesStyle() -> some View {
        self
            .padding()
            .background(Color.gray.opacity(0.1)) // Fondo suave
            .cornerRadius(12) // Bordes redondeados
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    func dailyNotesListStyle() -> some View {
        self
            .listStyle(.plain)
            .background(Color.gray.opacity(0.1)) // Fondo suave
    }
    
    func dailyNotesToolbarButton() -> some View {
        self
            .buttonStyle(.borderedProminent)
            .tint(Color.blue)
    }
}
