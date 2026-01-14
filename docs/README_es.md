<p align="center">
  <img src="HabitApp/Assets.xcassets/AppIcon.appiconset/icon 1.png" alt="HabitApp Logo" width="120"/>
</p>

<h1 align="center">🌀 HabitApp3 - Streaks & Accessibility 📝</h1>

<p align="center">
  <strong>Tu compañero inteligente para construir hábitos con rachas motivadoras y accesibilidad inclusiva</strong>
</p>

<p align="center">
  <a href="https://github.com/uallps/habitapp1/actions/workflows/ios.yml">
    <img src="https://github.com/uallps/habitapp1/actions/workflows/ios.yml/badge.svg" alt="CI/CD"/>
  </a>
  <img src="https://img.shields.io/badge/Swift-5.9-F05138?logo=swift&logoColor=white" alt="Swift"/>
  <img src="https://img.shields.io/badge/iOS-26+-007AFF?logo=apple&logoColor=white" alt="iOS"/>
  <img src="https://img.shields.io/badge/SwiftUI-4.0-0071E3?logo=swift&logoColor=white" alt="SwiftUI"/>
  <img src="https://img.shields.io/badge/Xcode-16.3-1575F9?logo=xcode&logoColor=white" alt="Xcode"/>
  <img src="https://img.shields.io/badge/License-MIT-success" alt="License"/>
</p>

<p align="center">
  <a href="#-características">Características</a> •
  <a href="#-arquitectura">Arquitectura</a> •
  <a href="#-equipo">Equipo</a>
</p>

Una aplicación multiplataforma (iOS/macOS) para gestionar hábitos diarios con sistema de rachas y accesibilidad avanzada.

## 🤔 ¿Qué es HabitApp3?

**HabitApp3** es una aplicación de aprendizaje construida en SwiftUI, enfocada en el seguimiento de rachas de hábitos y la implementación de características de accesibilidad como modos de tema claro/oscuro y soporte para daltónicos.

Esta aplicación forma parte de la asignatura Línea de Productos Software del grado Ingeniería Informática de la Universidad de Almería: [Más información](https://www.ual.es/estudios/grados/presentacion/plandeestudios/asignatura/4015/40154304)

---

## 👥 Equipo

<table>
<tr>
<td align="center" width="50%">
<img src="https://github.com/dgp336.png" width="80" style="border-radius:50%"/><br/>
<strong>David Granados Pérez</strong><br/>
<sub>🔥 Rachas, 👨‍🦯 Accesibilidad</sub><br/>
<a href="https://github.com/dgp336">@dgp336</a>
</td>
</tr>
</table>

<p align="center">
  <strong>Universidad de Almería</strong> • Línea de Productos Software • 4º Curso • 2025-2026
</p>

---

- **iOS**: Interfaz TabView optimizada para móviles
- **macOS**: NavigationSplitView con sidebar para escritorio

## Características de la Aplicación

<table>
<tr>
<td align="center" width="50%">
<img src="https://cdn-icons-png.flaticon.com/512/3767/3767084.png" width="60"/><br/>
<strong>Gestión de Hábitos</strong><br/>
<sub>Crea tus hábitos</sub>
</td>
<td align="center" width="50%">
<img src="https://i.redd.it/streak-flame-updated-v0-3n46sx7a0e9b1.png?width=283&format=png&auto=webp&s=74253ccd745fc4cf470e99c589921ce4d83c4d10" width="60"/><br/>
<strong>Rachas</strong><br/>
<sub>Motívate con tu propio progreso</sub>
</td>
</tr>
<tr>
<td align="center" width="50%">
<img src="https://rushplumbingseattle.com/images/ada-icon.png" width="60"/><br/>
<strong>Accesibilidad</strong><br/>
<sub>Funciones que facilitan el uso a todos los usuarios</sub>
</td>
<td align="center" width="50%">
<img src="https://cdn-icons-png.flaticon.com/512/1792/1792931.png" width="60"/><br/>
<strong>Recordatorios</strong><br/>
<sub>La aplicación te recuerda lo que se te olvida</sub>
</td>
</tr>
</table>

---

## 🔥 Funcionamiento Técnico de las Rachas

Las rachas (Streaks) son un sistema de motivación que rastrea la consistencia en la realización de hábitos. Cada vez que un usuario completa un hábito en el día esperado, la racha se incrementa.

### Modelo de Datos
- **Streak.swift**: Modelo SwiftData que almacena el ID del hábito, el conteo actual y la última actualización.
- Persistencia: Utiliza SwiftData para almacenar rachas de forma persistente.

### Vista de Badge
- **StreakBadgeView.swift**: Vista que muestra un ícono de llama con el número de días consecutivos.
- Animaciones: Efectos de rebote en el ícono cuando la racha aumenta.
- Colores: Fondo naranja para rachas normales, rojo para rachas "calientes" (>4 días).

### Lógica de Actualización
- Se actualiza automáticamente al completar hábitos.
- Reinicia si se rompe la secuencia diaria.

## 👨‍🦯 Sistema de Accesibilidad

El sistema de accesibilidad incluye modos de tema y ajustes para usuarios con daltonismo.

### Gestión de Temas
- **UserPreferences.swift**: Gestiona preferencias de UI, incluyendo tema (claro/oscuro/sistema), intensidad de modo noche y tipo de daltonismo.
- Temas: Claro, Oscuro, Sistema (sigue el dispositivo).
- Colores de acento: Azul, Rojo, Verde, etc.

### Modo Noche
- Overlay naranja semitransparente para reducir la luz azul.
- Intensidad ajustable por el usuario.

### Soporte para Daltónicos
- Filtros de color: Rotación de tono para Protanopía y Deuteranopía.
- Reducción de saturación para mejorar legibilidad.

### Implementación
- **AccessibilityFilterModifier.swift**: ViewModifier que aplica filtros de accesibilidad a toda la app.
- Integración: Se aplica globalmente usando el modifier en la raíz de la vista.

---

## 🗺️ Roadmap

- [] **v1.0** - Core de hábitos, Rachas, Accesibilidad

## 🎯 Funcionalidades por Versión

| Funcionalidad          | Básica | Premium |
| ---------------------- | --- | ----- |
| Hábitos               | ✅  | ✅    |
| Rachas                 | ✅  | ✅    |
| Accesibilidad          | ✅  | ✅    |
| Recordatorios          | ✅  | ✅    |

## 🏗️ Arquitectura del Proyecto

```
HabitApp/
├── Application/           # Configuración principal
├── Core/                 # Funcionalidad principal de hábitos
│   ├── Models/          # Habit.swift
│   ├── ViewModels/      # HabitListViewModel.swift
│   └── Views/           # Vistas de hábitos
├── Features/           # Funcionalidades específicas
│   ├── Streaks/         # Sistema de rachas
│   ├── Accessibility/   # Filtros de accesibilidad
│   └── Settings/        # Configuraciones de usuario
├── Infraestructure/
│   └── Plugins/         # Sistema de plugins
|   └── Persistence/     # Implementación de persistencia
└── Utils/               # Utilidades
```

## 📱 Plataformas Soportadas

- **iOS 17.0+**
- **macOS 14.0+**
- **SwiftUI + SwiftData**

## 🙏 Agradecimientos

- **Apple** por SwiftUI y SwiftData
- **Universidad de Almería** por ofrecer los Mac para el desarrollo
- Al equipo de HabitApp1 por tener un README tan profesional que ha inspirado este
- A todos los profesores y compañeros de la **Universidad de Almería**

<p align="center">
  <strong>⭐ Si te gusta este proyecto, ¡dale una estrella! ⭐</strong>
</p>

<p align="center">
  <a href="https://github.com/uallps/habitapp3/issues">Reportar Bug</a> •
  <a href="https://github.com/uallps/habitapp3/issues">Solicitar Feature</a> •
  <a href="https://github.com/uallps/habitapp3/pulls">Contribuir</a>
</p>

<p align="center">
  Made with ❤️ in Almería, Spain 🇪🇸
</p>


## 📄 Licencia

```
MIT License

Copyright (c) 2025-2026 HabitApp Team - Universidad de Almería

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
```