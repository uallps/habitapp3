import Foundation

/// Definición de un logro (catálogo predefinido)
struct AchievementDefinition {
    let id: String
    let title: String
    let description: String
    let iconName: String
}

/// Catálogo de logros disponibles
enum AchievementCatalog {
    static let all: [AchievementDefinition] = [
        // Primeros pasos
        AchievementDefinition(
            id: "first_habit",
            title: "Primer Paso",
            description: "Completa tu primer hábito",
            iconName: "star.fill"
        ),
        AchievementDefinition(
            id: "perfect_day",
            title: "Día Perfecto",
            description: "Completa todos tus hábitos programados en un día",
            iconName: "checkmark.seal.fill"
        ),
        
        // Cantidad de completados
        AchievementDefinition(
            id: "habits_5",
            title: "Principiante",
            description: "Completa 5 hábitos en total",
            iconName: "star.circle.fill"
        ),
        AchievementDefinition(
            id: "habits_25",
            title: "Dedicado",
            description: "Completa 25 hábitos en total",
            iconName: "flame.fill"
        ),
        AchievementDefinition(
            id: "habits_50",
            title: "Comprometido",
            description: "Completa 50 hábitos en total",
            iconName: "bolt.fill"
        ),
        AchievementDefinition(
            id: "habits_100",
            title: "Maestro",
            description: "Completa 100 hábitos en total",
            iconName: "crown.fill"
        ),
        
        // Racha
        AchievementDefinition(
            id: "streak_3",
            title: "En Racha",
            description: "Mantén una racha de 3 días consecutivos",
            iconName: "flame"
        ),
        AchievementDefinition(
            id: "streak_7",
            title: "Una Semana",
            description: "Mantén una racha de 7 días consecutivos",
            iconName: "calendar"
        ),
        
        // Horarios
        AchievementDefinition(
            id: "early_bird",
            title: "Madrugador",
            description: "Completa un hábito antes de las 8am",
            iconName: "sunrise.fill"
        ),
        
        // Variedad
        AchievementDefinition(
            id: "variety_5",
            title: "Versátil",
            description: "Completa al menos 5 hábitos diferentes",
            iconName: "sparkles"
        )
    ]
    
    /// Busca un logro por ID
    static func find(id: String) -> AchievementDefinition? {
        return all.first { $0.id == id }
    }
}
