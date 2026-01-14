import Foundation

/// Definición de un logro (catálogo predefinido)
struct AchievementDefinition {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let points: Int
}

/// Catálogo de logros disponibles
enum AchievementCatalog {
    static let all: [AchievementDefinition] = [
        // Primeros pasos
        AchievementDefinition(
            id: "first_habit",
            title: "Primer Paso",
            description: "Completa tu primer hábito",
            iconName: "star.fill",
            points: 10
        ),
        AchievementDefinition(
            id: "perfect_day",
            title: "Día Perfecto",
            description: "Completa todos tus hábitos programados en un día",
            iconName: "checkmark.seal.fill",
            points: 25
        ),
        
        // Cantidad de completados
        AchievementDefinition(
            id: "habits_5",
            title: "Principiante",
            description: "Completa 5 hábitos en total",
            iconName: "star.circle.fill",
            points: 10
        ),
        AchievementDefinition(
            id: "habits_25",
            title: "Dedicado",
            description: "Completa 25 hábitos en total",
            iconName: "flame.fill",
            points: 20
        ),
        AchievementDefinition(
            id: "habits_50",
            title: "Comprometido",
            description: "Completa 50 hábitos en total",
            iconName: "bolt.fill",
            points: 30
        ),
        AchievementDefinition(
            id: "habits_100",
            title: "Maestro",
            description: "Completa 100 hábitos en total",
            iconName: "crown.fill",
            points: 50
        ),
        
        // Racha (por hábito individual)
        AchievementDefinition(
            id: "streak_3",
            title: "En Racha",
            description: "Mantén una racha de 3 días consecutivos en un hábito",
            iconName: "flame",
            points: 15
        ),
        AchievementDefinition(
            id: "streak_7",
            title: "Una Semana",
            description: "Mantén una racha de 7 días consecutivos en un hábito",
            iconName: "calendar",
            points: 30
        ),
        
        // Racha global (cualquier hábito cada día)
        AchievementDefinition(
            id: "global_streak_7",
            title: "Constante",
            description: "Completa al menos un hábito durante 7 días consecutivos",
            iconName: "chart.line.uptrend.xyaxis",
            points: 25
        ),
        AchievementDefinition(
            id: "global_streak_30",
            title: "Imparable",
            description: "Completa al menos un hábito durante 30 días consecutivos",
            iconName: "bolt.horizontal.fill",
            points: 60
        ),
        
        // Variedad
        AchievementDefinition(
            id: "variety_5",
            title: "Versátil",
            description: "Completa al menos 5 hábitos diferentes",
            iconName: "sparkles",
            points: 20
        ),
        
        // Contexto: fin de semana
        AchievementDefinition(
            id: "weekend_aguafiestas",
            title: "Aguafiestas",
            description: "Completa al menos un hábito un sábado o un domingo",
            iconName: "party.popper",
            points: 15
        ),
        
        // Semana perfecta
        AchievementDefinition(
            id: "perfect_week",
            title: "Semana Impecable",
            description: "Completa todos tus hábitos programados durante 7 días seguidos",
            iconName: "calendar.circle",
            points: 50
        ),
        
        // Prioridad
        AchievementDefinition(
            id: "low_priority_done",
            title: "Cuidando lo pequeño",
            description: "Completa un hábito de prioridad baja",
            iconName: "tortoise.fill",
            points: 10
        ),
        AchievementDefinition(
            id: "high_priority_done",
            title: "Misión crítica",
            description: "Completa un hábito de prioridad alta",
            iconName: "exclamationmark.triangle.fill",
            points: 20
        )
    ]
    
    /// Busca un logro por ID
    static func find(id: String) -> AchievementDefinition? {
        return all.first { $0.id == id }
    }
}
