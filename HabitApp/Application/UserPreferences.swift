import SwiftUI
import Combine

// Responsabilidad: preferencias de UI persistidas en UserDefaults.
final class UserPreferences: ObservableObject {
    @AppStorage("showDueDates") private var storedShowDueDates: Bool = true
    @AppStorage("showPriorities") private var storedShowPriorities: Bool = true
    @AppStorage("enableReminders") private var storedEnableReminders: Bool = true
    @AppStorage("enableStreaks") private var storedEnableStreaks: Bool = true
    @AppStorage("enableStatistics") private var storedEnableStatistics: Bool = true
    @AppStorage("enableHabits") private var storedEnableHabits: Bool = true
    @AppStorage("enableGoals") private var storedEnableGoals: Bool = true
    @AppStorage("appTheme") private var storedAppTheme: Int = 0
    @AppStorage("daltonismType") var daltonismType: Int = 0
    @AppStorage("nightModeIntensity") var nightModeIntensity: Double = 0.0
    @AppStorage("accentColorName") var accentColorName: String = "Blue"
    @AppStorage("enableDailyNotes") private var storedEnableDailyNotes: Bool = true

    
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
    
    var showDueDates: Bool {
        get { storedShowDueDates }
        set { objectWillChange.send(); storedShowDueDates = newValue }
    }
    
    var enableGoals: Bool {
        get { storedEnableGoals }
        set { objectWillChange.send(); storedEnableGoals = newValue }
    }
    
    var showPriorities: Bool {
        get { storedShowPriorities }
        set { objectWillChange.send(); storedShowPriorities = newValue }
    }
    
    var enableReminders: Bool {
        get { storedEnableReminders }
        set { objectWillChange.send(); storedEnableReminders = newValue }
    }
    
    var enableHabits: Bool {
        get { storedEnableHabits }
        set { objectWillChange.send(); storedEnableHabits = newValue }
    }
    
    var enableStatistics: Bool {
        get { storedEnableStatistics }
        set { objectWillChange.send(); storedEnableStatistics = newValue }
    }
    
    var enableStreaks: Bool {
        get { storedEnableStreaks }
        set { objectWillChange.send(); storedEnableStreaks = newValue }
    }
    
    var enableDailyNotes: Bool {
        get { storedEnableDailyNotes }
        set { objectWillChange.send(); storedEnableDailyNotes = newValue }
    }
}
