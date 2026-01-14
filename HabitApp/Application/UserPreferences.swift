import SwiftUI
import Combine

// Responsabilidad: preferencias de UI y características persistidas en UserDefaults.
final class UserPreferences: ObservableObject {
    // #if HABIT_FEATURE
    // @AppStorage("showDueDates") private var storedShowDueDates: Bool = true
    // @AppStorage("showPriorities") private var storedShowPriorities: Bool = true
    // @AppStorage("enableReminders") private var storedEnableReminders: Bool = true
    // #else
    // @AppStorage("showDueDates") private var storedShowDueDates: Bool = false
    // @AppStorage("showPriorities") private var storedShowPriorities: Bool = false
    // @AppStorage("enableReminders") private var storedEnableReminders: Bool = false
    // #endif
    // #if STREAK_FEATURE
    // @AppStorage("enableStreaks") private var storedEnableStreaks: Bool = true
    // #else
    // @AppStorage("enableStreaks") private var storedEnableStreaks: Bool = false
    // #endif
    // #if STATISTIC_FEATURE
    // @AppStorage("enableStatistics") private var storedEnableStatistics: Bool = true
    // #else
    // @AppStorage("enableStatistics") private var storedEnableStatistics: Bool = false
    // #endif
    // #if 
    // @AppStorage("enableHabits") private var storedEnableHabits: Bool = true
    // @AppStorage("enableGoals") private var storedEnableGoals: Bool = true
    // @AppStorage("enableAddictions") private var storedEnableAddictions: Bool = true
    // @AppStorage("enableCategories") private var storedEnableCategories: Bool = true
    // @AppStorage("appTheme") private var storedAppTheme: Int = 0
    // @AppStorage("daltonismType") var daltonismType: Int = 0
    // @AppStorage("nightModeIntensity") var nightModeIntensity: Double = 0.0
    // @AppStorage("accentColorName") var accentColorName: String = "Blue"
    // @AppStorage("enableDailyNotes") private var storedEnableDailyNotes: Bool = true
    
#if HABIT_FEATURE
@AppStorage("showDueDates") private var storedShowDueDates: Bool = true
@AppStorage("showPriorities") private var storedShowPriorities: Bool = true
@AppStorage("enableReminders") private var storedEnableReminders: Bool = true
#else
@AppStorage("showDueDates") private var storedShowDueDates: Bool = false
@AppStorage("showPriorities") private var storedShowPriorities: Bool = false
@AppStorage("enableReminders") private var storedEnableReminders: Bool = false
#endif

#if STREAK_FEATURE
@AppStorage("enableStreaks") private var storedEnableStreaks: Bool = true
#else
@AppStorage("enableStreaks") private var storedEnableStreaks: Bool = false
#endif

#if STATISTIC_FEATURE
@AppStorage("enableStatistics") private var storedEnableStatistics: Bool = true
#else
@AppStorage("enableStatistics") private var storedEnableStatistics: Bool = false
#endif

#if HABIT_FEATURE
@AppStorage("enableHabits") private var storedEnableHabits: Bool = true
#else
@AppStorage("enableHabits") private var storedEnableHabits: Bool = false
#endif

#if GOAL_FEATURE
@AppStorage("enableGoals") private var storedEnableGoals: Bool = true
#else
@AppStorage("enableGoals") private var storedEnableGoals: Bool = false
#endif

#if ADDICTION_FEATURE
@AppStorage("enableAddictions") private var storedEnableAddictions: Bool = true
#else
@AppStorage("enableAddictions") private var storedEnableAddictions: Bool = false
#endif

#if CATEGORY_FEATURE
@AppStorage("enableCategories") private var storedEnableCategories: Bool = true
#else
@AppStorage("enableCategories") private var storedEnableCategories: Bool = false
#endif

#if SETTING_FEATURE
@AppStorage("appTheme") private var storedAppTheme: Int = 0
@AppStorage("daltonismType") var daltonismType: Int = 0
@AppStorage("nightModeIntensity") var nightModeIntensity: Double = 0.0
@AppStorage("accentColorName") var accentColorName: String = "Blue"
#else
@AppStorage("appTheme") private var storedAppTheme: Int = 0
@AppStorage("daltonismType") var daltonismType: Int = 0
@AppStorage("nightModeIntensity") var nightModeIntensity: Double = 0.0
@AppStorage("accentColorName") var accentColorName: String = "Blue"
#endif

#if DAILY_NOTE_FEATURE
@AppStorage("enableDailyNotes") private var storedEnableDailyNotes: Bool = true
#else
@AppStorage("enableDailyNotes") private var storedEnableDailyNotes: Bool = false
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
    
    var showDueDates: Bool {
        get { storedShowDueDates }
        set { objectWillChange.send(); storedShowDueDates = newValue }
    }
    
    var enableGoals: Bool {
        get { storedEnableGoals }
        set { objectWillChange.send(); storedEnableGoals = newValue }
    }
    
    var enableCategories: Bool {
        get { storedEnableCategories }
        set { objectWillChange.send(); storedEnableCategories = newValue }
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
    
    var enableAddictions: Bool {
        get { storedEnableAddictions }
        set { objectWillChange.send(); storedEnableAddictions = newValue }
    }
}
