# HabitApp - Sistema de Hábitos y Notas

Una aplicación multiplataforma (iOS/macOS) para gestionar hábitos diarios y notas con sistema de notificaciones inteligentes.

## 🚀 Características Principales

### 📱 **Multiplataforma**

- **iOS**: Interfaz TabView optimizada para móviles
- **macOS**: NavigationSplitView con sidebar para escritorio

### ✅ **Gestión de Hábitos**

- Crear hábitos con días específicos de la semana
- Marcar como completado/incompleto por día
- Sistema de prioridades (Alta, Media, Baja)

### 📝 **Notas Diarias**

- Notas independientes por fecha
- Notas asociadas a hábitos específicos
- Filtrado automático por día seleccionado

### 🎯 **Objetivos** (Solo iOS)

- Crear objetivos con metas numéricas
- Hitos intermedios
- Seguimiento de progreso automático
- Asociación con hábitos

## 🔔 Sistema de Notificaciones

### **Arquitectura de Plugins**

El sistema utiliza una arquitectura de plugins para manejar notificaciones:

```swift
// 1. Protocolo base
protocol TaskDataObservingPlugin {
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?)
}

// 2. Manager central
TaskDataObserverManager.shared.notify(
    taskId: UUID(),
    title: "Título de la notificación",
    date: fechaFutura
)

// 3. Plugin de recordatorios
struct ReminderPlugin: TaskDataObservingPlugin {
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        // Programa alerta UIKit para iOS
        // Log en consola para macOS
    }
}
```

### **Tipos de Notificaciones**

#### **📝 Notas Futuras**

```swift
// En DailyNotesViewModel.addNote()
if noteDate > today {
    TaskDataObserverManager.shared.notify(
        taskId: note.id,
        title: "Nota: \(title)",
        date: noteDate
    )
}
```

#### **🏃‍♂️ Notas de Hábitos**

```swift
// En AddNoteView.saveNote()
let notificationTitle = habit != nil ? 
    "Hábito: \(habit!.title) - \(title)" : 
    "Nota: \(title)"
  
TaskDataObserverManager.shared.notify(
    taskId: note.id,
    title: notificationTitle,
    date: normalizedDate
)
```

#### **📅 Recordatorio de Hábitos Diarios**

```swift
// En HabitListViewModel.scheduleHabitsNotification()
func scheduleHabitsNotification(for date: Date, habits: [Habit]) {
    let dayHabits = habits.filter { $0.scheduledDays.contains(weekday) }
    let habitTitles = dayHabits.map { $0.title }.joined(separator: ", ")
  
    TaskDataObserverManager.shared.notify(
        taskId: UUID(),
        title: "Hoy tienes \(dayHabits.count) hábito(s): \(habitTitles)",
        date: notificationDate // 9:00 AM del día
    )
}
```

### **Implementación de Alertas**

#### **iOS - UIAlertController**

```swift
#if os(iOS)
private func showAlert(title: String, message: String) {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else { return }
  
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
  
    if let topController = window.rootViewController?.topMostViewController() {
        topController.present(alert, animated: true)
    }
}
#endif
```

#### **macOS - Console Log**

```swift
#if os(macOS)
print("🔔 Alerta en macOS: \(title) - \(message)")
#endif
```

## 🧪 Testing de Notificaciones

### **TestReminderView**

Incluye botones para probar el sistema:

- **"Test Plugin Directo"**: Prueba el plugin con alerta en 3s
- **"Alerta en 3s/5s"**: Alertas programadas con DispatchQueue
- **"Alerta Inmediata"**: Muestra alerta al instante
- **"Test Hábitos Mañana"**: Programa notificación de hábitos para mañana

### **Uso del Sistema**

```swift
// 1. Para programar una notificación
TaskDataObserverManager.shared.notify(
    taskId: UUID(),
    title: "Mi recordatorio",
    date: Date().addingTimeInterval(3600) // En 1 hora
)

// 2. El manager notifica a todos los plugins registrados
// 3. ReminderPlugin programa la alerta
// 4. La alerta se muestra en el momento programado
```

## 🏗️ Arquitectura del Proyecto

```
HabitApp/
├── Application/           # Configuración principal
├── Core/                 # Funcionalidad principal de hábitos
│   ├── Models/          # Habit.swift
│   ├── ViewModels/      # HabitListViewModel.swift
│   └── Views/           # Vistas de hábitos
├── feature/
│   ├── DailyNotes/      # Sistema de notas
│   ├── Goals/           # Objetivos (solo iOS)
│   └── TestNoti/        # Testing de notificaciones
├── infraestructure/
│   └── Plugins/         # Sistema de plugins y notificaciones
└── Utils/               # Extensiones y utilidades
```

## 🔧 Configuración

### **Permisos iOS**

```swift
// En HabitApp.swift
UNUserNotificationCenter.current().requestAuthorization(
    options: [.alert, .sound, .badge]
) { granted, error in
    // Manejo de permisos
}
```

### **Compilación Condicional**

```swift
#if os(iOS)
// Código específico para iOS
#else
// Código específico para macOS
#endif
```

## 📱 Plataformas Soportadas

- **iOS 17.0+**
- **macOS 14.0+**
- **SwiftUI + SwiftData**

## 🎯 Funcionalidades por Plataforma

| Funcionalidad          | iOS | macOS |
| ---------------------- | --- | ----- |
| Hábitos               | ✅  | ✅    |
| Notas Diarias          | ✅  | ✅    |
| Objetivos              | ✅  | ❌    |
| Notificaciones UIKit   | ✅  | ❌    |
| Notificaciones Console | ❌  | ✅    |
| Test Notificaciones    | ✅  | ✅    |
