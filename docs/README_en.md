<p align="center">
  <img src="HabitApp/Assets.xcassets/AppIcon.appiconset/icon 1.png" alt="HabitApp Logo" width="120"/>
</p>

<h1 align="center">🌀 HabitApp3 📝</h1>

<p align="center">
  <strong>Your smart companion to build habits that transform your life</strong>
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
  <a href="#-features">Features</a> •
  <a href="#-architecture">Architecture</a> •
  <a href="#-team">Team</a>
</p>

A cross-platform app (iOS/macOS) for managing daily habits with a streak system and advanced accessibility features.

## 🤔 What is HabitApp3?

**HabitApp3** is a learning app built in SwiftUI, focused on habit streak tracking and implementing accessibility features such as light/dark theme modes and colorblind support.

This app is part of the Software Product Line course of the Computer Engineering degree at the University of Almería: [More information](https://www.ual.es/estudios/grados/presentacion/plandeestudios/asignatura/4015/40154304)

---

## 👥 Team

<table>
<tr>
<td align="center" width="50%">
<img src="https://github.com/dgp336.png" width="80" style="border-radius:50%"/><br/>
<strong>David Granados Pérez</strong><br/>
<sub>🔥 Streaks, 👨‍🦯 Accessibility</sub><br/>
<a href="https://github.com/dgp336">@dgp336</a>
</td>
</tr>
</table>

<p align="center">
  <strong>University of Almería</strong> • Software Product Line • 4th Year • 2025-2026
</p>

---

- **iOS**: TabView interface optimized for mobile
- **macOS**: NavigationSplitView with sidebar for desktop

## App Features

<table>
<tr>
<td align="center" width="50%">
<img src="https://cdn-icons-png.flaticon.com/512/3767/3767084.png" width="60"/><br/>
<strong>Habit Management</strong><br/>
<sub>Create your habits</sub>
</td>
<td align="center" width="50%">
<img src="https://i.redd.it/streak-flame-updated-v0-3n46sx7a0e9b1.png?width=283&format=png&auto=webp&s=74253ccd745fc4cf470e99c589921ce4d83c4d10" width="60"/><br/>
<strong>Streaks</strong><br/>
<sub>Motivate yourself with your own progress</sub>
</td>
</tr>
<tr>
<td align="center" width="50%">
<img src="https://rushplumbingseattle.com/images/ada-icon.png" width="60"/><br/>
<strong>Accessibility</strong><br/>
<sub>Features that make it easier for everyone to use</sub>
</td>
<td align="center" width="50%">
<img src="https://cdn-icons-png.flaticon.com/512/1792/1792931.png" width="60"/><br/>
<strong>Reminders</strong><br/>
<sub>The app reminds you of what you forget</sub>
</td>
</tr>
</table>

---

## 🔥 Technical Operation of Streaks

Streaks are a motivation system that tracks consistency in performing habits. Each time a user completes a habit on the expected day, the streak increases.

### Data Model
- **Streak.swift**: SwiftData model that stores the habit ID, current count, and last update.
- Persistence: Uses SwiftData for persistent streak storage.

### Badge View
- **StreakBadgeView.swift**: View that displays a flame icon with the number of consecutive days.
- Animations: Bounce effects on the icon when the streak increases.
- Colors: Orange background for normal streaks, red for "hot" streaks (>4 days).

### Update Logic
- Automatically updates when habits are completed.
- Resets if the daily sequence is broken.

## 👨‍🦯 Accessibility System

The accessibility system includes theme modes and adjustments for colorblind users.

### Theme Management
- **UserPreferences.swift**: Manages UI preferences, including theme (light/dark/system), night mode intensity, and colorblind type.
- Themes: Light, Dark, System (follows device).
- Accent Colors: Blue, Red, Green, etc.

### Night Mode
- Semi-transparent orange overlay to reduce blue light.
- Adjustable intensity by the user.

### Colorblind Support
- Color filters: Hue rotation for Protanopia and Deuteranopia.
- Saturation reduction for better readability.

### Implementation
- **AccessibilityFilterModifier.swift**: ViewModifier that applies accessibility filters to the entire app.
- Integration: Applied globally using the modifier at the view root.

---

## 🗺️ Roadmap

- [] **v1.0** - Core habits, Streaks, Accessibility

## 🎯 Features by Version

| Feature          | Basic | Premium |
| ---------------- | --- | ----- |
| Habits           | ✅  | ✅    |
| Streaks          | ✅  | ✅    |
| Accessibility    | ✅  | ✅    |
| Reminders        | ✅  | ✅    |

## 🏗️ Project Architecture

```
HabitApp/
├── Application/           # Main configuration
├── Core/                  # Core habit functionality
│   ├── Models/           # Habit.swift
│   ├── ViewModels/       # HabitListViewModel.swift
│   └── Views/            # Habit views
├── Features/           # Specific functionalities
│   ├── Streaks/         # Streak system
│   ├── Accessibility/   # Accessibility filters
│   └── Settings/        # User settings
├── Infrastructure/
│   └── Plugins/          # Plugin system
│   └── Persistence/      # Persistence implementation
└── Utils/                # Utilities
```

## 📱 Supported Platforms

- **iOS 17.0+**
- **macOS 14.0+**
- **SwiftUI + SwiftData**

## 🙏 Acknowledgements

- **Apple** for SwiftUI and SwiftData
- **University of Almería** for providing Macs for development
- The HabitApp1 team for having such a professional README that inspired this one
- All professors and classmates at the **University of Almería**

<p align="center">
  <strong>⭐ If you like this project, give it a star! ⭐</strong>
</p>

<p align="center">
  <a href="https://github.com/uallps/habitapp3/issues">Report Bug</a> •
  <a href="https://github.com/uallps/habitapp3/issues">Request Feature</a> •
  <a href="https://github.com/uallps/habitapp3/pulls">Contribute</a>
</p>

<p align="center">
  Made with ❤️ in Almería, Spain 🇪🇸
</p>

## 📄 License

```
MIT License

Copyright (c) 2025-2026 HabitApp Team - University of Almería

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
