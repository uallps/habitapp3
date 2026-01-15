
# 🔌 Arquitectura Modular de Plugins - HabitApp

## 📋 Índice

1. [Introducción](#introducción)
2. [Jerarquía de Protocolos](#jerarquía-de-protocolos)
3. [Desacoplamiento](#desacoplamiento)
4. [Patrones de Diseño](#patrones-de-diseño)
5. [Flujo de Datos](#flujo-de-datos)
6. [Implementaciones Específicas](#implementaciones-específicas)
7. [Ventajas de la Arquitectura](#ventajas)

---

## Introducción

Esta aplicación implementa una **arquitectura modular basada en plugins** que permite añadir funcionalidades sin modificar el núcleo (core) de la aplicación. El sistema utiliza múltiples patrones de diseño para lograr un **bajo acoplamiento** y **alta cohesión**.

### Pregunta Clave Respondida

**¿Cómo se inyecta tu código en la app principal sin aumentar el acoplamiento del núcleo?**

**Respuesta:** A través de:

- Protocol-Based Programming
- Dependency Injection
- Observer Pattern
- Registry Pattern
- Runtime Discovery (Reflexión)
- Type Erasure

---

## Jerarquía de Protocolos

```
FeaturePlugin (Base)
    ├── DataPlugin (Maneja datos)
    │   └── HabitDataObservingPlugin (Observa cambios en habits/notas)
    │       ├── HabitGoalPlugin ✅
    └── ViewPlugin (Provee vistas)
        ├── DarkModePlugin
        └── AccessibilityPlugin
```

### Protocolo Base: `FeaturePlugin`

**Ubicación:** `HabitApp/Infraestructure/Plugins/FeaturePlugin.swift`

```swift
protocol FeaturePlugin: AnyObject {
    /// Modelos de datos que el plugin necesita persistir
    var models: [any PersistentModel.Type] { get }
  
    /// Indica si el plugin está habilitado
    var isEnabled: Bool { get }
  
    /// Inicializador requerido con Dependency Injection
    init(config: AppConfig)
}
```

**Características:**

- **Contrato base** que todos los plugins deben cumplir
- **Dependency Injection** mediante `init(config:)`
- **Type Erasure** con `[any PersistentModel.Type]`

### Protocolo Especializado: `HabitDataObservingPlugin`

**Ubicación:** `HabitApp/Infraestructure/Plugins/HabitDataObservingPlugin.swift`

```swift
protocol HabitDataObservingPlugin: DataPlugin {
    /// Se llama cuando un "task" (nota o hábito) cambia o se crea
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?)
}
```

**Propósito:** Permitir que plugins reaccionen a cambios en datos sin acoplarse directamente a los modelos.

---

## Desacoplamiento

### 1. Inyección por Protocolo (Protocol-Based Injection)

**El núcleo NO conoce las implementaciones concretas**, solo los protocolos.

#### Ejemplo: DailyNotesPlugin

**Ubicación:** `HabitApp/Infraestructure/Plugins/DailyNotesPlugin.swift`

```swift
final class DailyNotesPlugin: FeaturePlugin {
    var models: [any PersistentModel.Type]
    var isEnabled: Bool
    let config: AppConfig
  
    init(config: AppConfig) {
        self.isEnabled = true
        self.models = [Habit.self, DailyNote.self]
        self.config = config
    }
}
```

**Ventajas:**

- Solo declara sus modelos
- NO modifica el core
- Se puede activar/desactivar dinámicamente

#### Ejemplo: HabitGoalPlugin

**Ubicación:** `HabitApp/Infraestructure/Plugins/HabitGoalPlugin.swift`

```swift
final class HabitGoalPlugin: HabitDataObservingPlugin {
    var models: [any PersistentModel.Type]
    var isEnabled: Bool
    let config: AppConfig
  
    init(config: AppConfig) {
        self.isEnabled = config.userPreferences.enableGoals
        self.models = [Goal.self, Milestone.self]
        self.config = config
    }
  
    // Observa cambios SIN modificar Habit o DailyNote
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        Task {
            try await config.storageProvider.onDataChanged(
                taskId: taskId, 
                title: title, 
                dueDate: dueDate
            )
        }
    }
}
```

**Características:**

- **Goal comprueba el estado del habit** a través del observer pattern
- NO se acopla directamente al modelo `Habit`
- Respeta el principio Open/Closed

### 2. Plugins NO Modifican el Core

```
CORE (Inmutable)
  ├── Habit.swift
  ├── HabitListViewModel.swift
  └── HabitListView.swift

PLUGINS (Extensibles)
  ├── DailyNotesPlugin → Añade notas sin tocar Habit
  └── HabitGoalPlugin → Monitorea habits sin modificarlos
```

---

## Patrones de Diseño

### 1. Observer Pattern

**Implementación:** `HabitDataObserverManager`

**Ubicación:** `HabitApp/Infraestructure/Plugins/HabitDataObserverManager.swift`

```swift
final class HabitDataObserverManager {
    static let shared = HabitDataObserverManager()
    private init() {}
  
    private var plugins: [HabitDataObservingPlugin] = []
  
    func register(_ plugin: HabitDataObservingPlugin) {
        plugins.append(plugin)  // ✅ Registro dinámico
    }
  
    func notify(taskId: UUID, title: String, date: Date?) {
        plugins.forEach { 
            $0.onDataChanged(taskId: taskId, title: title, dueDate: date)
        }  // ✅ Notificación polimórfica
    }
}
```

**Ventajas:**

- **Desacoplamiento total:** El emisor no conoce a los receptores
- **Escalabilidad:** Añadir observadores no requiere modificar código existente
- **Polimorfismo:** Todos los plugins se notifican con la misma interfaz

**Flujo:**

```
Habit cambia
    ↓
HabitDataObserverManager.notify()
    ↓
    ├─→ HabitGoalPlugin.onDataChanged() → Actualiza Goals
    ├─→ StreakPlugin.onDataChanged() → Actualiza Streaks
    └─→ CategoryPlugin.onDataChanged() → Actualiza Categorías
```

### 2. Registry Pattern

**Implementación:** `PluginRegistry`

**Ubicación:** `HabitApp/Infraestructure/Plugins/PluginRegistry.swift`

```swift
class PluginRegistry {
    static let shared = PluginRegistry()
  
    private(set) var registeredPlugins: [FeaturePlugin.Type] = []
    private var pluginInstances: [FeaturePlugin] = []
  
    private init() {}
  
    /// Registra un nuevo tipo de plugin
    func register(_ pluginType: FeaturePlugin.Type) {
        guard !registeredPlugins.contains(where: { $0 == pluginType }) else {
            return
        }
        registeredPlugins.append(pluginType)
        print("🔌 Plugin registrado: \(pluginType)")
    }
  
    /// Crea instancias de todos los plugins registrados
    func createPluginInstances(config: AppConfig) -> [FeaturePlugin] {
        pluginInstances = registeredPlugins.map { pluginType in
            pluginType.init(config: config)  // ✅ DI aquí
        }
        return pluginInstances
    }
  
    /// Obtiene todos los modelos (siempre todos para evitar errores de schema)
    func getEnabledModels(from plugins: [FeaturePlugin]) -> [any PersistentModel.Type] {
        return plugins.flatMap { $0.models }
    }
}
```

**Ventajas:**

- **Centralización:** Un único punto de registro
- **Type Safety:** Solo acepta `FeaturePlugin.Type`
- **Lazy Instantiation:** Crea instancias solo cuando es necesario

### 3. Discovery Pattern (Reflexión)

**Implementación:** `PluginDiscovery`

**Ubicación:** `HabitApp/Infraestructure/Plugins/PluginDiscovery.swift`

```swift
class PluginDiscovery {
    /// Descubre automáticamente todas las clases que implementan FeaturePlugin
    static func discoverPlugins() -> [FeaturePlugin.Type] {
        var plugins: [FeaturePlugin.Type] = []
    
        // Obtener todas las clases del runtime
        let expectedClassCount = objc_getClassList(nil, 0)
        let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
        let actualClassCount = objc_getClassList(autoreleasingAllClasses, expectedClassCount)
    
        for i in 0 ..< actualClassCount {
            if let currentClass = allClasses[Int(i)] {
                let className = NSStringFromClass(currentClass)
            
                // Filtrar solo clases de nuestro módulo
                let isFromOurBundle = className.hasPrefix("HabitApp")
                guard isFromOurBundle else { continue }
            
                // Verificar si implementa FeaturePlugin
                if let pluginType = currentClass as? FeaturePlugin.Type {
                    plugins.append(pluginType)
                }
            }
        }
    
        allClasses.deallocate()
        return plugins
    }
}
```

**Ventajas:**

- **Descubrimiento automático:** No necesitas registrar manualmente
- **Extensibilidad:** Añadir un nuevo plugin es solo crear la clase
- **Convención sobre configuración:** El sistema lo detecta automáticamente

### 4. Dependency Injection

**Implementación:** Constructor Injection en `AppConfig`

**Ubicación:** `HabitApp/Application/AppConfig.swift`

```swift
class AppConfig: ObservableObject {
    @MainActor static let shared = AppConfig()
  
    private var plugins: [FeaturePlugin] = []
    var userPreferences: UserPreferences = UserPreferences()
    var storageProvider: StorageProvider { ... }
  
    @MainActor
    private init() {
        // 1️⃣ Descubrir plugins automáticamente
        let discoveredPlugins = PluginDiscovery.discoverPlugins()
    
        // 2️⃣ Registrar en el Registry
        for pluginType in discoveredPlugins {
            PluginRegistry.shared.register(pluginType)
        }
    
        // 3️⃣ Crear instancias con DI
        self.plugins = PluginRegistry.shared.createPluginInstances(config: self)
    
        // 4️⃣ Recopilar modelos de TODOS los plugins
        var rawSchemas: [any PersistentModel.Type] = []
        rawSchemas.append(contentsOf: PluginRegistry.shared.getEnabledModels(from: plugins))
    
        // Eliminar duplicados
        var seenSchemas: Set<ObjectIdentifier> = []
        var schemas: [any PersistentModel.Type] = []
        for model in rawSchemas {
            let id = ObjectIdentifier(model)
            if seenSchemas.insert(id).inserted {
                schemas.append(model)
            }
        }
    
        // 5️⃣ Configurar persistencia
        let schema = Schema(schemas)
        self.swiftDataStorageProvider = SwiftDataStorageProvider(schema: schema)
    
        // 6️⃣ Registrar observers
        setupHabitDataObservingPlugins()
    }
  
    private func setupHabitDataObservingPlugins() {
        let manager = HabitDataObserverManager.shared
        manager.register(HabitGoalPlugin(config: self))
        manager.register(StreakPlugin(config: self))
        print("✅ Plugins observadores registrados")
    }
}
```

**Inyección en múltiples niveles:**

```
AppConfig
    ↓ (inyecta config)
FeaturePlugin
    ↓ (accede a)
StorageProvider, UserPreferences
```

---

## Flujo de Datos

### Caso de Uso: Usuario crea una nota para un Habit

```
1. Usuario interactúa con UI
   ↓
2. HabitListViewModel.toggleCompletion(habit)
   ↓
3. HabitDataObserverManager.shared.notify(
       taskId: habit.id,
       title: habit.title,
       date: habit.dueDate
   )
   ↓
4. Manager notifica a TODOS los plugins registrados
   ↓
   ├─→ HabitGoalPlugin.onDataChanged()
   │       ↓
   │       ├─ Busca Goals asociados al Habit
   │       ├─ Actualiza progreso: goal.progress += 1
   │       └─ Marca milestone como completado si aplica

```

### Código del ViewModel

**Ubicación:** `HabitApp/Core/ViewModels/HabitListViewModel.swift`

```swift
func toggleCompletion(for habit: Habit) {
    // 1. Actualizar el habit
    habit.isCompleted.toggle()
  
    // 2. Guardar en persistencia
    try? modelContext.save()
  
    // 3. Notificar a los observadores (SIN conocer quiénes son)
    HabitDataObserverManager.shared.notifyDataChanged(
        taskId: habit.id,
        title: habit.title,
        dueDate: habit.dueDate
    )
}
```

**Clave:** `HabitListViewModel` **NO conoce** a `HabitGoalPlugin`, solo notifica al manager.

---

## Implementaciones Específicas

### 1. DailyNotesPlugin

**Funcionalidad:** Permite asociar notas a hábitos.

**Características:**

- Siempre habilitado (`isEnabled = true`)
- Registra modelos: `Habit`, `DailyNote`
- NO implementa `onDataChanged` (no necesita observar)

**Código:**

```swift
final class DailyNotesPlugin: FeaturePlugin {
    var models: [any PersistentModel.Type]
    var isEnabled: Bool
    let config: AppConfig
  
    init(config: AppConfig) {
        self.isEnabled = true
        self.models = [Habit.self, DailyNote.self]
        self.config = config
    }
}
```

### 2. HabitGoalPlugin

**Funcionalidad:** Comprueba el estado del habit y actualiza objetivos.

**Características:**

- Habilitado según preferencias del usuario
- Registra modelos: `Goal`, `Milestone`
- Implementa `HabitDataObservingPlugin`
- Reacciona a cambios en habits

**Código:**

```swift
final class HabitGoalPlugin: HabitDataObservingPlugin {
    var models: [any PersistentModel.Type]
    var isEnabled: Bool
    let config: AppConfig
  
    init(config: AppConfig) {
        self.isEnabled = config.userPreferences.enableGoals
        self.models = [Goal.self, Milestone.self]
        self.config = config
    }
  
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        Task {
            // Buscar goals asociados al habit
            let goals = try await config.storageProvider.fetchGoals(for: taskId)
        
            // Actualizar progreso
            for goal in goals {
                goal.currentProgress += 1
            
                // Verificar si se completó un milestone
                if goal.currentProgress >= goal.targetValue {
                    goal.isCompleted = true
                }
            }
        
            try await config.storageProvider.save()
        }
    }
}
```

### 3. HabitDataObserverManager

**Funcionalidad:** Coordina la notificación a todos los plugins observadores.

**Patrón:** Singleton + Observer

**Características:**

- Registro dinámico de observadores
- Notificación broadcast a todos los plugins
- Desacoplamiento total entre emisor y receptores

---

## Ventajas de la Arquitectura

| Principio/Patrón                | Implementación                              | Ventaja                                                                |
| -------------------------------- | -------------------------------------------- | ---------------------------------------------------------------------- |
| **Open/Closed Principle**  | Nuevos plugins sin modificar core            | Puedes añadir `RewardPlugin` sin tocar código existente            |
| **Separation of Concerns** | Cada plugin maneja su dominio                | Goals no conocen la implementación de Habits                          |
| **Dependency Inversion**   | Dependencia de abstracciones (protocolos)    | El core depende de `FeaturePlugin`, no de implementaciones concretas |
| **Single Responsibility**  | Cada plugin tiene una responsabilidad única | `DailyNotesPlugin` solo maneja notas                                 |
| **Testability**            | Plugins se pueden mockear                    | Puedes crear `MockGoalPlugin` para tests                             |
| **Scalability**            | Añadir features = crear nuevo plugin        | Sistema crece sin complejidad exponencial                              |
| **Runtime Discovery**      | Detección automática de plugins            | No requiere configuración manual                                      |
| **Type Safety**            | Protocolos garantizan contratos              | Errores en tiempo de compilación, no runtime                          |

---

## Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────┐
│                   HabitApp                      │
│              (Punto de Entrada)                 │
└────────────────────┬────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────┐
│                  AppConfig                      │
│         (Dependency Injection Container)         │
│                                                 │
│  ┌──────────────────────────────────────────┐  │
│  │      PluginDiscovery.discoverPlugins()   │  │
│  └──────────────────┬───────────────────────┘  │
│                     ↓                           │
│  ┌──────────────────────────────────────────┐  │
│  │     PluginRegistry.register(plugins)     │  │
│  └──────────────────┬───────────────────────┘  │
│                     ↓                           │
│  ┌──────────────────────────────────────────┐  │
│  │  pluginInstances = registry.create()     │  │
│  └──────────────────┬───────────────────────┘  │
└───────────────────┬─┴───────────────────────────┘
                    │
        ┌───────────┴──────────┐
        ↓                      ↓
┌───────────────┐      ┌──────────────────┐
│ PluginRegistry│      │ ObserverManager  │
└───────┬───────┘      └────────┬─────────┘
        │                       │
        ↓                       ↓
┌─────────────────────────────────────────┐
│           Plugin Instances               │
│                                          │
│  ┌──────────────┐  ┌─────────────────┐ │
│  │DailyNotesPlg │  │ HabitGoalPlugin │ │
│  └──────────────┘  └─────────────────┘ │
│                                          │
│  ┌──────────────┐  ┌─────────────────┐ │
│  │ StreakPlugin │  │ CategoryPlugin  │ │
│  └──────────────┘  └─────────────────┘ │
└─────────────────────────────────────────┘
         │                       │
         ↓                       ↓
┌─────────────────┐    ┌────────────────┐
│   Data Models   │    │  Observations  │
│  (SwiftData)    │    │   (Events)     │
└─────────────────┘    └────────────────┘
```

---

## Cómo Añadir un Nuevo Plugin

### Ejemplo: RewardPlugin

```swift
// 1️⃣ Crear el plugin implementando FeaturePlugin
final class RewardPlugin: HabitDataObservingPlugin {
    var models: [any PersistentModel.Type]
    var isEnabled: Bool
    let config: AppConfig
  
    init(config: AppConfig) {
        self.isEnabled = config.userPreferences.enableRewards
        self.models = [Reward.self]
        self.config = config
    }
  
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        // Lógica: Otorgar puntos cuando se completa un habit
        Task {
            let points = calculatePoints(for: taskId)
            try await config.storageProvider.addReward(points: points)
        }
    }
}

// 2️⃣ NO REQUIERE MÁS CAMBIOS
// PluginDiscovery lo detectará automáticamente
// PluginRegistry lo registrará
// AppConfig lo instanciará con DI
```

**¡Eso es todo!** No necesitas modificar:

- `AppConfig`
- `PluginRegistry`
- `HabitListViewModel`
- Ningún archivo del core

---

## Conclusión

Esta arquitectura demuestra cómo implementar un sistema de plugins **altamente desacoplado** usando:

1. **Protocol-Oriented Programming** para contratos claros
2. **Dependency Injection** para proveer dependencias
3. **Observer Pattern** para reactividad sin acoplamiento
4. **Registry Pattern** para gestión centralizada
5. **Runtime Discovery** para automatización
6. **Type Erasure** para polimorfismo

**Resultado:** Un sistema que cumple con SOLID, es testeable, escalable y mantenible.

---

## Referencias

- **FeaturePlugin.swift:** Protocolo base
- **PluginRegistry.swift:** Registro centralizado
- **PluginDiscovery.swift:** Descubrimiento automático
- **HabitDataObserverManager.swift:** Coordinador de observadores
- **AppConfig.swift:** Contenedor de dependencias
- **DailyNotesPlugin.swift:** Implementación de notas
- **HabitGoalPlugin.swift:** Implementación de objetivos

---

**Última actualización:** 15 de enero de 2026
**Autor:** Equipo de Desarrollo HabitApp3
