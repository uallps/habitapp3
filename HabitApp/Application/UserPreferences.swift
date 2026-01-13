import SwiftUI
import Combine

// Responsabilidad: preferencias de UI persistidas en UserDefaults.
final class UserPreferences: ObservableObject {
    @AppStorage("showDueDates") private var storedShowDueDates: Bool = true
    @AppStorage("showPriorities") private var storedShowPriorities: Bool = true
    @AppStorage("enableReminders") private var storedEnableReminders: Bool = true
    @AppStorage("enableHabits") private var storedEnableHabits: Bool = true
    @AppStorage("enableGoals") private var storedEnableGoals: Bool = true
    @AppStorage("enableDailyNotes") private var storedEnableDailyNotes: Bool = true
    @AppStorage("appTheme") private var storedAppTheme: Int = 0
    
    var appTheme: Int {
        get { storedAppTheme }
        set { objectWillChange.send(); storedAppTheme = newValue }
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
    
    var enableDailyNotes: Bool {
        get { storedEnableDailyNotes }
        set { objectWillChange.send(); storedEnableDailyNotes = newValue }
    }
}
