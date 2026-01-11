import SwiftUI
import Combine

// Responsabilidad: preferencias de UI persistidas en UserDefaults.
final class UserPreferences: ObservableObject {
    @AppStorage("showDueDates") private var storedShowDueDates: Bool = true
    @AppStorage("showPriorities") private var storedShowPriorities: Bool = true
    @AppStorage("enableReminders") private var storedEnableReminders: Bool = true
    @AppStorage("enableStreaks") private var storedEnableStreaks: Bool = true
    @AppStorage("enableStatistics") private var storedEnableStatistics: Bool = true
    @AppStorage("appTheme") private var storedAppTheme: Int = 0

        var appTheme: Int {
            get { storedAppTheme }
            set { objectWillChange.send(); storedAppTheme = newValue }
        }
        
        // Helper para convertir el Int en ColorScheme de SwiftUI
        var colorScheme: ColorScheme? {
            switch appTheme {
            case 1: return .light
            case 2: return .dark
            default: return nil // Sistema
            }
        }
    
    var showDueDates: Bool {
        get { storedShowDueDates }
        set { objectWillChange.send(); storedShowDueDates = newValue }
    }
    
    var showPriorities: Bool {
        get { storedShowPriorities }
        set { objectWillChange.send(); storedShowPriorities = newValue }
    }
    
    var enableReminders: Bool {
        get { storedEnableReminders }
        set { objectWillChange.send(); storedEnableReminders = newValue }
    }
    
    var enableStatistics: Bool {
        get { storedEnableStatistics }
        set { objectWillChange.send(); storedEnableStatistics = newValue }
    }
    
    var enableStreaks: Bool {
        get { storedEnableStreaks }
        set { objectWillChange.send(); storedEnableStreaks = newValue }
    }
}
