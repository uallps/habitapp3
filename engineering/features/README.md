# Estadísticas y Logros: Arquitectura y Patrones de Diseño

Este documento describe la implementación de las funcionalidades de **Estadísticas** y **Logros** en HabitApp, con énfasis en los patrones de diseño utilizados y cómo se respeta la arquitectura MVVM.

---

## 🏗️ Arquitectura General

Ambas funcionalidades siguen estrictamente el patrón **MVVM (Model-View-ViewModel)** y están diseñadas como **plugins modulares** que tratan de respetar los principios SOLID.

### Principios Arquitectónicos Aplicados

#### 1. **Separación de Responsabilidades (SoC)**
- **Model**: Estructuras de datos inmutables y entidades de persistencia
- **View**: SwiftUI views puramente declarativas
- **ViewModel**: Lógica de presentación y gestión de estado
- **Service**: Lógica de negocio y cálculos complejos

#### 2. **Plugin Pattern**
Implementación modular mediante el protocolo `FeaturePlugin`:
```swift
protocol FeaturePlugin: AnyObject {
    var models: [any PersistentModel.Type] { get }
    var isEnabled: Bool { get }
    init(config: AppConfig)
}
```

#### 3. **Dependency Injection**
ViewModels reciben sus dependencias mediante inyección:
```swift
class AchievementsViewModel: ObservableObject {
    let storageProvider: StorageProvider
    init(storageProvider: StorageProvider) { ... }
}
```

---

## 📊 Sistema de Estadísticas

### Descripción General
Proporciona visualizaciones y métricas sobre el rendimiento de los hábitos del usuario, siguiendo una arquitectura limpia y testeable.

### Arquitectura MVVM

#### Estructura de Capas
```
HabitApp/Features/Statistics/
├── Models/                         # CAPA MODEL
│   └── StatsModels.swift          # Value types inmutables
├── Services/                       # CAPA SERVICE
│   └── StatisticsService.swift    # Lógica de negocio pura
├── ViewModels/                     # CAPA VIEWMODEL
│   └── StatisticsViewModel.swift  # Estado + transformación de datos
└── Views/                          # CAPA VIEW
    ├── StatisticsView.swift       # Vista contenedora
    ├── OverviewStatsView.swift    # Subvista general
    ├── PerHabitStatsView.swift    # Subvista por hábito
    ├── StatsChartView.swift       # Componente gráfico
    ├── CompactHabitStatsView.swift
    └── DonutChartView.swift       # Componente gráfico
```

#### Patrones de Diseño Implementados

##### 1. **Plugin Pattern + Feature Toggle**
```swift
final class StatisticsPlugin: FeaturePlugin {
    var isEnabled: Bool              // Feature flag
    var models: [any PersistentModel.Type] = []
    
    init(config: AppConfig) {
        self.isEnabled = config.userPreferences.enableStatistics
    }
}
```
**Beneficios**:
- Activación/desactivación sin recompilar
- Testing independiente de features
- Deploy incremental de funcionalidades

##### 2. **Service Layer Pattern**
```swift
final class StatisticsService {
    // Lógica de negocio PURA (sin dependencias de UI)
    func computeGeneralStats(from habits: [Habit], range: TimeRange) -> GeneralStats
    func computeHabitStats(for habit: Habit, range: TimeRange) -> HabitStats
}
```
**Beneficios**:
- Testeable sin UI
- Reutilizable en diferentes contextos
- Sin efectos secundarios

##### 3. **ViewModel Pattern (MVVM)**
```swift
@MainActor
final class StatisticsViewModel: ObservableObject {
    // Estado observable (@Published)
    @Published var selectedRange: TimeRange = .week
    @Published var generalStats: GeneralStats?
    @Published var habitStats: [HabitStats] = []
    @Published var isLoading = false
    
    // Dependencia inyectada
    private let service = StatisticsService()
    
    // Transformación: datos brutos → datos presentables
    func loadStatistics(from habits: [Habit]) {
        generalStats = service.computeGeneralStats(from: habits, range: selectedRange)
        habitStats = habits.map { service.computeHabitStats(for: $0, range: selectedRange) }
    }
}
```
**Responsabilidades del ViewModel**:
- ✅ Gestionar estado de UI (`@Published`)
- ✅ Coordinar llamadas a servicios
- ✅ Transformar datos del Model al formato de la View
- ❌ NO contiene lógica de negocio (delegada a Service)
- ❌ NO importa SwiftUI (excepto decoradores)

##### 4. **Value Object Pattern**
```swift
struct GeneralStats {                    // Inmutable
    let range: TimeRange
    let periods: [PeriodData]
    let totalCompleted: Int
    let totalExpected: Int
    
    var overallRate: Double {            // Computed property
        guard totalExpected > 0 else { return 0 }
        return Double(totalCompleted) / Double(totalExpected)
    }
}
```
**Beneficios**:
- Inmutabilidad (thread-safe)
- Valor semántico claro
- Fácil de testear

##### 5. **SwiftUI Data Flow**
```swift
struct StatisticsView: View {
    @Query private var habits: [Habit]           // Fuente de verdad (SwiftData)
    @StateObject private var viewModel = ...     // Estado local
    
    var body: some View {
        // Vista declara DEPENDENCIAS del estado
        OverviewStatsView(stats: viewModel.generalStats)
            .onChange(of: habits) { _, newHabits in
                viewModel.loadStatistics(from: newHabits)  // Reacción a cambios
            }
    }
}
```
**Flujo unidireccional**:
```
SwiftData → @Query → View → ViewModel → Service → Model → ViewModel → View
```

### Modelos de Datos (Value Types)

#### TimeRange (Enum)
#### TimeRange (Enum)
Define los períodos temporales disponibles:
```swift
enum TimeRange: String, CaseIterable {
    case day = "Hoy"
    case week = "Semana"
}
```

#### PeriodData (Struct)
Representa los datos de un período específico:
```swift
struct PeriodData {
    let label: String           // Etiqueta mostrada (ej: "Lun 14")
    let date: Date              // Fecha del período
    let completedCount: Int     // Hábitos completados
    let expectedCount: Int      // Hábitos esperados
    
    var completionRate: Double  // Tasa de cumplimiento (0.0 - 1.0)
}
```

#### GeneralStats
Estadísticas agregadas de todos los hábitos:
```swift
struct GeneralStats {
    let range: TimeRange        // Período temporal
    let periods: [PeriodData]   // Datos por período
    let totalCompleted: Int     // Total completados en el rango
    let totalExpected: Int      // Total esperados en el rango
    
    var overallRate: Double     // Tasa general de cumplimiento
}
```

#### HabitStats
Estadísticas de un hábito específico:
```swift
struct HabitStats {
    let id: UUID                // ID del hábito
    let title: String           // Nombre del hábito
    let range: TimeRange        // Período temporal
    let periods: [PeriodData]   // Datos por período
    
    var totalCompleted: Int     // Total completados
    var totalExpected: Int      // Total esperados
    var overallRate: Double     // Tasa de cumplimiento
}
```

### Servicio de Cálculo (StatisticsService)

#### Métodos principales

**`computeGeneralStats(from:range:)`**
- Calcula estadísticas agregadas de todos los hábitos
- Genera datos por período (día o semana)
- Suma completados y esperados de todos los hábitos

**`computeHabitStats(for:range:)`**
- Calcula estadísticas de un hábito específico
- Genera datos por período para ese hábito

#### Lógica de cálculo

**Períodos de tiempo:**
```swift
switch range {
case .day:
    // Retorna solo el día actual
    
case .week:
    // Retorna 7 días desde el domingo hasta el sábado de la semana actual
    // Usa el mismo cálculo que HabitListView para consistencia
}
```

**Conteo de completados:**
- Verifica si el hábito tiene una fecha de completado en el día especificado
- Retorna 1 si está completado, 0 si no

**Conteo de esperados:**
- Verifica si el hábito está programado para ese día de la semana
- Retorna 1 si está programado, 0 si no

### Características Visuales

1. **Vista General (OverviewStatsView)**
   - Muestra estadísticas agregadas de todos los hábitos
   - Gráficos de barras por período
   - Tasa de cumplimiento general

2. **Vista por Hábito (PerHabitStatsView)**
   - Lista de hábitos con sus estadísticas individuales
   - Gráficos compactos por hábito
   - Detalle de cumplimiento

3. **Gráficos**
   - Gráfico de barras (`StatsChartView`)
   - Gráfico circular/dona (`DonutChartView`)

### Cómo funciona

1. **Activación**: El plugin se habilita desde `UserPreferences.enableStatistics`
2. **Lectura de datos**: El ViewModel obtiene los hábitos desde el `StorageProvider`
3. **Cálculo**: `StatisticsService` procesa los hábitos y genera las métricas
4. **Visualización**: Las vistas muestran los datos calculados con gráficos

---

## 🏆 Sistema de Logros

### Descripción General
El sistema de logros gamifica la experiencia del usuario mediante recompensas por alcanzar diferentes hitos. Los logros se desbloquean automáticamente cuando el usuario cumple ciertas condiciones, otorgando puntos que determinan el nivel del jugador.

### Arquitectura

#### Ubicación de archivos
```
HabitApp/Features/Achievements/
├── Models/
│   ├── Achievement.swift              # Modelo de logro desbloqueado
│   ├── AchievementDefinition.swift    # Catálogo de logros
│   └── AchievementLevel.swift         # Niveles por puntuación
├── ViewModels/
│   └── AchievementsViewModel.swift    # Lógica de desbloqueo
└── Views/
    ├── AchievementsListView.swift     # Vista principal
    ├── AchievementRowView.swift       # Fila de logro
    └── ScoreHeaderView.swift          # Cabecera con puntuación
```

#### Plugin
```swift
// HabitApp/Infraestructure/Plugins/AchievementsPlugin.swift
final class AchievementsPlugin: FeaturePlugin {
    var isEnabled: Bool          // Se controla desde UserPreferences
    var models: [Achievement.self] // Requiere modelo de Achievement
}
```

### Modelos de Datos

#### Achievement (SwiftData Model)
Representa un logro en el estado del usuario:
```swift
@Model
final class Achievement {
    var id: UUID                    // ID único
    var achievementId: String       // ID del catálogo
    var title: String               // Título del logro
    var achievementDescription: String // Descripción
    var iconName: String            // Icono SF Symbol
    var unlockedAt: Date?           // Fecha de desbloqueo
    var isUnlocked: Bool            // Estado
}
```

#### AchievementDefinition
Define un logro en el catálogo:
```swift
struct AchievementDefinition {
    let id: String           // Identificador único
    let title: String        // Título
    let description: String  // Descripción de requisito
    let iconName: String     // Icono SF Symbol
    let points: Int          // Puntos otorgados
}
```

#### AchievementLevel
Niveles basados en puntuación total:
```swift
enum AchievementLevel {
    case none           // 0 puntos
    case beginner       // 1-119 puntos
    case intermediate   // 120-299 puntos
    case advanced       // 300+ puntos
}
```

### Catálogo de Logros

El sistema incluye 17 logros predefinidos en `AchievementCatalog`:

#### Primeros Pasos
- **Primer Paso** (10 pts): Completa tu primer hábito
- **Día Perfecto** (25 pts): Completa todos tus hábitos programados en un día

#### Cantidad de Completados
- **Principiante** (10 pts): Completa 5 hábitos en total
- **Dedicado** (20 pts): Completa 25 hábitos en total
- **Comprometido** (30 pts): Completa 50 hábitos en total
- **Maestro** (50 pts): Completa 100 hábitos en total

#### Rachas Individuales
- **En Racha** (15 pts): Mantén una racha de 3 días consecutivos en un hábito
- **Una Semana** (30 pts): Mantén una racha de 7 días consecutivos en un hábito

#### Rachas Globales
- **Constante** (25 pts): Completa al menos un hábito durante 7 días consecutivos
- **Imparable** (60 pts): Completa al menos un hábito durante 30 días consecutivos

#### Variedad
- **Versátil** (20 pts): Completa al menos 5 hábitos diferentes

#### Contexto Temporal
- **Aguafiestas** (15 pts): Completa al menos un hábito un sábado o domingo
- **Semana Impecable** (50 pts): Completa todos tus hábitos durante 7 días seguidos

#### Prioridad
- **Cuidando lo pequeño** (10 pts): Completa un hábito de prioridad baja
- **Misión crítica** (20 pts): Completa un hábito de prioridad alta

### Funcionamiento del Sistema

#### 1. Sincronización del Catálogo
```swift
syncCatalogIfNeeded()
```
- Ejecutado al inicio de la app
- Crea logros en base de datos para todos los del catálogo
- Elimina logros obsoletos que ya no existen en el catálogo
- Mantiene el estado de logros desbloqueados

#### 2. Verificación de Logros
```swift
checkAndUnlockAchievements(habits: [Habit])
```
- Se ejecuta después de cada cambio en hábitos
- Calcula métricas globales:
  - Total de completados
  - Hábitos únicos completados
  - Racha máxima individual
  - Racha global
  - Días perfectos
  - Semanas perfectas
  - Completados en fin de semana
  - Completados por prioridad

#### 3. Lógica de Desbloqueo

Para cada logro bloqueado, se evalúa su condición:

```swift
switch achievementId {
case "first_habit":
    shouldUnlock = totalCompletions >= 1
    
case "streak_7":
    shouldUnlock = maxHabitStreak >= 7
    
case "perfect_week":
    shouldUnlock = hasPerfectWeek
    
// ... etc
}
```

Si la condición se cumple:
- `isUnlocked = true`
- `unlockedAt = Date()`
- Se guarda en la base de datos

#### 4. Sistema de Puntuación

```swift
totalScore(for achievements: [Achievement]) -> Int
```
- Suma los puntos de todos los logros desbloqueados
- Determina el nivel del usuario
- Se muestra en `ScoreHeaderView`

### Métricas Calculadas

#### Racha Individual (Max Streak)
- Días consecutivos completando un mismo hábito
- Se calcula para cada hábito y se toma el máximo

#### Racha Global
- Días consecutivos con al menos un hábito completado
- No importa qué hábito específico

#### Día Perfecto
- Todos los hábitos programados para ese día están completados
- Solo cuenta hábitos que están activos ese día de la semana

#### Semana Perfecta
- Ventana de 7 días consecutivos donde cada día es un "día perfecto"
- Debe existir al menos una secuencia de 7 días perfectos

### Integración con la App

#### Habilitación/Deshabilitación
```swift
// AppConfig.swift / UserPreferences.swift
@AppStorage("enableAchievements") var enableAchievements = true
```

#### Observador de Cambios
El sistema usa `HabitDataObserverManager` para detectar cuando:
- Se completa un hábito
- Se crea un nuevo hábito
- Se modifica un hábito

Cuando ocurre un cambio, se dispara `checkAndUnlockAchievements()` automáticamente.

#### Persistencia
- Los logros se guardan en SwiftData
- Comparten el mismo `ModelContainer` que los hábitos
- Se sincronizan en cada inicio de la app

---

## 🔧 Configuración y Uso

### Habilitar/Deshabilitar Funcionalidades

Ambas funcionalidades se controlan desde `UserPreferences`:

```swift
@AppStorage("enableStatistics") var enableStatistics = true
@AppStorage("enableAchievements") var enableAchievements = true
```

Se pueden cambiar desde:
1. **SettingsView**: Interfaz de usuario para el usuario
2. **AppConfig**: Configuración por defecto en código

### Plugins

Los plugins son registrados automáticamente en `PluginRegistry`:

```swift
let registry = PluginRegistry(config: config)
registry.register(StatisticsPlugin.self)
registry.register(AchievementsPlugin.self)
```

Si un plugin está deshabilitado:
- Sus modelos no se cargan en SwiftData
- Sus vistas no se muestran en la navegación
- Su lógica no se ejecuta

---

## 🎯 Flujo de Datos

### Estadísticas
```
Usuario → HabitListViewModel → StorageProvider → SwiftData
                                       ↓
                           StatisticsViewModel
                                       ↓
                           StatisticsService (cálculo)
                                       ↓
                           StatisticsView (visualización)
```

### Logros
```
Usuario completa hábito → HabitListViewModel → StorageProvider
                                                      ↓
                              HabitDataObserverManager (notifica)
                                                      ↓
                              AchievementsViewModel.checkAndUnlock
                                                      ↓
                              Calcula métricas → Evalúa condiciones
                                                      ↓
                              Desbloquea logros → Guarda en SwiftData
                                                      ↓
                              AchievementsListView (muestra nuevos logros)
```

---

## 📝 Notas Técnicas

### Estadísticas
- No requiere modelos adicionales de SwiftData
- Los cálculos son en tiempo real (no se cachean)
- La semana siempre va de Domingo (1) a Sábado (7)
- Compatible con cualquier frecuencia de hábito

### Logros
- Requiere modelo `Achievement` en SwiftData
- El catálogo es inmutable (definido en código)
- La sincronización ocurre en cada inicio
- Los logros nunca se "rebloquean"
- La puntuación es acumulativa e irreversible

### Performance
- Las estadísticas recalculan en cada cambio de vista/rango
- Los logros solo se verifican después de cambios en hábitos
- Ambos sistemas son eficientes para < 100 hábitos
- Para optimizar: considerar caché o cálculos asíncronos

---

## � Referencias

### Archivos Clave - Estadísticas
- [StatsModels.swift](../HabitApp/Features/Statistics/Models/StatsModels.swift) - Models
- [StatisticsService.swift](../HabitApp/Features/Statistics/Services/StatisticsService.swift) - Service Layer
- [StatisticsViewModel.swift](../HabitApp/Features/Statistics/ViewModels/StatisticsViewModel.swift) - ViewModel
- [StatisticsView.swift](../HabitApp/Features/Statistics/Views/StatisticsView.swift) - View
- [StatisticsPlugin.swift](../HabitApp/Infraestructure/Plugins/StatisticsPlugin.swift) - Plugin

### Archivos Clave - Logros
- [Achievement.swift](../HabitApp/Features/Achievements/Models/Achievement.swift) - Entity
- [AchievementDefinition.swift](../HabitApp/Features/Achievements/Models/AchievementDefinition.swift) - Catalog
- [AchievementLevel.swift](../HabitApp/Features/Achievements/Models/AchievementLevel.swift) - Smart Enum
- [AchievementsViewModel.swift](../HabitApp/Features/Achievements/ViewModels/AchievementsViewModel.swift) - ViewModel
- [AchievementsListView.swift](../HabitApp/Features/Achievements/Views/AchievementsListView.swift) - View
- [AchievementsPlugin.swift](../HabitApp/Infraestructure/Plugins/AchievementsPlugin.swift) - Plugin
