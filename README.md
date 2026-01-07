<p align="center">
  <img src="HabitApp/Assets.xcassets/AppIcon.appiconset/icon 1.png" alt="HabitApp Logo" width="120"/>
</p>

<h1 align="center">🌀 HabitApp3 📝</h1>

<p align="center">
  <strong>Tu compañero inteligente para construir hábitos que transforman tu vida</strong>
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
  <a href="#-capturas">Capturas</a> •
  <a href="#-instalación">Instalación</a> •
  <a href="#-arquitectura">Arquitectura</a> •
  <a href="#-gamificación">Gamificación</a> •
  <a href="#-equipo">Equipo</a>
</p>

---

## 🤔 ¿Qué es HabitApp3?

**HabitApp3** es una aplicación de aprendizaje construida en SwiftUI, un framework que promete construir simultáneamente en iOS y MacOS moderna y elegante diseñada para ayudarte a **construir hábitos positivos** y **alcanzar tus metas**.

<table>
<tr>
<td width="50%">

### Objetivos y Metas

</td>
<td width="50%">

### Adicciones y Multilenguaje
- Sugerencias de hábitos con GPT-4 Vision

</td>
</tr>
<tr>
<td width="50%">

### ❓ Característica Personal 3
- Captura de fotos para hábitos
- Modelado 3D con LiDAR
- Resúmenes visuales tipo "stories"

</td>
<td width="50%">

### ❓ Característica Personal 4
- Multilenguaje (ES/EN)
- Modo claro/oscuro/auto
- Estadísticas detalladas

### ❓ Característica Personal 5

</td>
</tr>
</table>

---

## 🗂️ Características

<table>
<tr>
<td align="center" width="25%">
<img src="https://cdn-icons-png.flaticon.com/512/3767/3767084.png" width="60"/><br/>
<strong>Gestión de Hábitos</strong><br/>
<sub>Organiza tus hábitos y agrúpalos de manera personalizada</sub>
</td>
<td align="center" width="25%">
<img src="https://i.redd.it/streak-flame-updated-v0-3n46sx7a0e9b1.png?width=283&format=png&auto=webp&s=74253ccd745fc4cf470e99c589921ce4d83c4d10" width="60"/><br/>
<strong>Rachas</strong><br/>
<sub>Motívate con tu propio progreso</sub>
</td>
<td align="center" width="25%">
<img src="https://cdn-icons-png.flaticon.com/512/1792/1792931.png" width="60"/><br/>
<strong>Recordatorios</strong><br/>
<sub>La aplicación te recuerda lo que se te olvida</sub>
</td>
<td align="center" width="25%">
<img src="https://cdn-icons-png.flaticon.com/512/5136/5136407.png" width="60"/><br/>
<strong>Estadísticas</strong><br/>
<sub>Visualiza tu progreso con gráficos detallados</sub>
</td>
</tr>
</table>

---

## 📸 Capturas

---

## 🛠 Instalación

### Requisitos

| Requisito | Versión |
|-----------|---------|
| macOS | Sequoia ? |
| Xcode | ? |
| iOS Deployment Target | ? |
| Swift | ? |

### Pasos

---

## 👷🏻‍♂️ Arquitectura

HabitApp3 utiliza el patrón arquitectónico **Model View ViewModel**, así como una **arquitectura modular** basada en el patrón **Plugin** que permite añadir funcionalidades sin modificar el núcleo.

TODO: Modificar con lo nuestro
```
┌─────────────────────────────────────────────────────────────┐
│                     🎯 HabitApp Core                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │ ContentView │  │ HabitStore  │  │  AppConfig  │          │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘          │
│         └────────────────┼────────────────┘                  │
│                          ▼                                   │
│              ┌───────────────────────┐                       │
│              │   📦 ModuleRegistry   │                       │
│              │   (Service Locator)   │                       │
│              └───────────┬───────────┘                       │
└──────────────────────────┼───────────────────────────────────┘
                           │
     ┌─────────────────────┼─────────────────────┐
     │           │         │         │           │
     ▼           ▼         ▼         ▼           ▼
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
│ 📢 Ads  │ │ 📸 3D   │ │ 🤖 AI   │ │ 📊 Recap│ │ 🎮 Game │
│ Module  │ │ Module  │ │ Module  │ │ Module  │ │ Module  │
└─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘
```

### Módulos Disponibles

| Módulo | Autor | Estado | Descripción |
|--------|-------|:------:|-------------|
|  |  |  |  |
---


---

## 📚 Documentación

| Documento | Descripción |
|-----------|-------------|
|  |  |


---

## �� Roadmap

- [] **v1.0** - MVP: Categorías, Rachas, Estadísticas, Notas Diarias y Recordatoeios

---

## 👥 Equipo

<table>
<tr>
<td align="center" width="20%">
<img src="https://github.com/ualfsp323.png" width="80" style="border-radius:50%"/><br/>
<strong>Franco Sergio Pereyra</strong><br/>
<sub>📝 Notas Diarias & 🎨 Appearance</sub><br/>
<a href="https://github.com/ualfsp323">@ualfsp323</a>
</td>
<td align="center" width="20%">
<img src="https://github.com/ifm562-ual.png" width="80" style="border-radius:50%"/><br/>
<strong>Ismael Fernández Méndez</strong><br/>
<sub>🗂️ Categorías, 🚬 Adicciones y 🌍 MultiLenguaje</sub><br/>
<a href="https://github.com/ifm562-ual">@ifm562-ual</a>
</td>
<td align="center" width="20%">
<img src="https://github.com/dgp336.png" width="80" style="border-radius:50%"/><br/>
<strong>David Granados Pérez</strong><br/>
<sub>🔥 Rachas</sub><br/>
<a href="https://github.com/dgp336">@dgp336</a>
</td>
<td align="center" width="20%">
<img src="https://github.com/ualjfr498.png" width="80" style="border-radius:50%"/><br/>
<strong>Juan José Fernández Requena</strong><br/>
<sub>📊 Estadísticas</sub><br/>
<a href="https://github.com/jgm847">@ualjfr498</a>
</td>
<td align="center" width="20%">
<img src="https://github.com/dcf313.png" width="80" style="border-radius:50%"/><br/>
<strong></strong><br/>
<sub>🔔 Recordatorios</sub><br/>
<a href="https://github.com/dcf313">@dcf313</a>
</td>
</tr>
</table>

<p align="center">
  <strong>Universidad de Almería</strong> • Línea de Productos Software • 4º Curso • 2025-2026
</p>

---

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

---

## 🙏 Agradecimientos

- **Apple** por SwiftUI y SwiftData
- **Universidad de Almería** por ofrecer los Mac para el desarrollo
- Al equipo de HabitApp1 por tener un README tan profesional que ha inspirado este
- A todos los profesores y compañeros de la **Universidad de Almería**

---

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

