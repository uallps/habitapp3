
---

# HabitApp

**HabitApp** es una aplicación de ejemplo en **SwiftUI + SwiftData** para iOS y macOS que permite gestionar hábitos, notas diarias y recordatorios locales. Está estructurada siguiendo un enfoque **MVVM** y soporta plugins para extender su funcionalidad.

---

## 📁 Estructura del proyecto

```
HabitApp/
│
├── App/
│   └── HabitApp.swift            # Punto de entrada @main con TabView (iOS) y NavigationSplitView (macOS)
│
├── Models/
│   └── DailyNote.swift           # Modelo de nota diaria usando @Model de SwiftData
│
├── ViewModels/
│   └── DailyNotesViewModel.swift # Lógica de negocio para notas diarias (iOS + macOS)
│
├── Views/
│   ├── DailyNotesView.swift      # Vista principal de notas diarias unificada iOS/macOS
│   ├── AddNoteView.swift         # Vista para crear nuevas notas, unificada iOS/macOS
│   ├── NoteDetailView.swift      # Vista detalle de nota
│   └── NoteRowView.swift         # Fila individual en la lista de notas
│
├── Extensions/
│   └── ViewModifiers.swift       # ViewModifiers para estilizar listas y botones
│
├── Plugins/
│   ├── PluginRegistry.swift
│   ├── TaskDataObservingPlugin.swift # Protocolo para plugins que observan cambios en datos (habit o nota)
│   └── ReminderPlugin.swift      # Plugin para programar notificaciones locales
│
└── README.md
```

---

## 🛠 Tecnologías usadas

* **SwiftUI**: interfaz declarativa para iOS/macOS.
* **SwiftData**: persistencia de modelos (`DailyNote`) usando `@Model`, `ModelContainer` y `ModelContext`.
* **Combine**: para publicar cambios de datos en el ViewModel.
* **UserNotifications**: notificaciones locales en iOS.
* Arquitectura **MVVM**.
* Plugins para extender funcionalidad (como recordatorios).

---

## 💡 Funcionalidades principales

### 1️⃣ Habit List (iOS/macOS)

* Pantalla principal de hábitos (placeholder en este ejemplo).
* Tab en iOS y NavigationSplitView en macOS.

### 2️⃣ Daily Notes

* Crear, editar y borrar notas.
* Lista de notas filtradas por fecha.
* Fecha limitada entre hoy y 3 meses en el futuro.
* Vista unificada para iOS/macOS usando `#if os(iOS)`.

### 3️⃣ Reminder Plugin

* **ReminderPlugin** observa cambios en los datos de las notas.
* Cuando se crea o actualiza una nota con fecha futura, programa una notificación local en iOS.
* En macOS se puede extender a `NSUserNotificationCenter` si se desea.
* Permite verificar notificaciones pendientes usando:

```swift
UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
    for r in requests {
        print("Notificación pendiente: \(r.identifier) - \(r.content.title)")
    }
}
```

### 4️⃣ Testing de Notificaciones

* `TestReminderView` permite crear notas con notificación en 10s para verificar que el plugin funciona.
* Funciona mejor en un **dispositivo real iOS**, ya que el simulador no siempre muestra alertas.

---

## ⚙️ Integración iOS/macOS

* iOS: `TabView` + `NavigationStack`
* macOS: `NavigationSplitView`
* Vistas unificadas mediante `#if os(iOS) / #else / #endif`
* `DailyNotesViewModel` funciona en ambas plataformas usando el mismo archivo.

---

## 📝 Notas técnicas importantes

1. **Permisos de notificaciones iOS**

```swift
UNUserNotificationCenter.current().requestAuthorization(
    options: [.alert, .sound, .badge]
) { granted, error in ... }
```



2. **SwiftData**

* Modelos anotados con `@Model`.
* `ModelContainer(for: [DailyNote.self])` y `ModelContext(container)` permiten inicializar el ViewModel.

3. **Estilos**

* `ViewModifiers` para listas y botones:

  * `.dailyNotesStyle()`
  * `.dailyNotesListStyle()`
  * `.dailyNotesToolbarButton()`

---



## 📌 Consejos

* Las notificaciones no se muestran en el simulador de iOS como alertas visuales, solo en la consola.
* Para macOS, se requiere adaptar `ReminderPlugin` a `NSUserNotificationCenter` si se quieren notificaciones reales.
* Mantener `DailyNotesViewModel` unificado permite usar el mismo código en iOS y macOS.

---

