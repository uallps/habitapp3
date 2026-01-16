import SwiftUI
import Combine

// Responsabilidad: preferencias de UI y características persistidas en UserDefaults.
final class UserPreferences: ObservableObject {
    
#if STREAK_FEATURE
@AppStorage("enableStreaks") private var storedEnableStreaks: Bool = true
#else
@AppStorage("enableStreaks") private var storedEnableStreaks: Bool = false
#endif

#if HABIT_FEATURE
@AppStorage("enableHabits") private var storedEnableHabits: Bool = true
#else
@AppStorage("enableHabits") private var storedEnableHabits: Bool = false
#endif

#if SETTING_FEATURE
@AppStorage("enableSettings") private var storedEnableSettings: Bool = true
@AppStorage("appTheme") private var storedAppTheme: Int = 0
@AppStorage("daltonismType") var daltonismType: Int = 0
@AppStorage("nightModeIntensity") var nightModeIntensity: Double = 0.0
@AppStorage("accentColorName") var accentColorName: String = "Blue"
#else
@AppStorage("enableSettings") private var storedEnableSettings: Bool = false
@AppStorage("appTheme") private var storedAppTheme: Int = 0
@AppStorage("daltonismType") var daltonismType: Int = 0
@AppStorage("nightModeIntensity") var nightModeIntensity: Double = 0.0
@AppStorage("accentColorName") var accentColorName: String = "Blue"
#endif
    
    var appTheme: Int {
        get { storedAppTheme }
        set { objectWillChange.send(); storedAppTheme = newValue }
    }
        
    var colorScheme: ColorScheme? {
        switch appTheme {
        case 1: return .light
        case 2: return .dark
        default: return nil // Sistema
        }
    }
    
    var accentColor: Color {
            switch accentColorName {
                case "Red": return .red
                case "Green": return .green
                case "Orange": return .orange
                case "Purple": return .purple
                case "Pink": return .pink
                default: return .blue
            }
        }
    
    var enableSettings: Bool {
        get { storedEnableSettings }
        set { objectWillChange.send(); storedEnableSettings = newValue }
    }
    
    var enableHabits: Bool {
        get { storedEnableHabits }
        set { objectWillChange.send(); storedEnableHabits = newValue }
    }
    
    var enableStreaks: Bool {
        get { storedEnableStreaks }
        set { objectWillChange.send(); storedEnableStreaks = newValue }
    }
}
