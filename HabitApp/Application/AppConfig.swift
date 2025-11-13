import SwiftUI
import Combine

// ObservableObject is a protocol that ensure this class has data that, when changed, trigger UI updates. Similar concept to mutable states in Jetpack Compose.
class AppConfig: ObservableObject  {

    // @AppStorage connects a property to UserDefaults automatically.

    // UserDefaults in Swift (and iOS/macOS development) is a simple key-value storage system that allows your app to persist small amounts of data across launches.
    // It shouldn't be a relational DB like SQLlite databases on Android apps. It only stores small data directly to disk, no relationship between them.
    // So basically, any property marked as @AppStorage is read or written given the correct circumstances.

    @AppStorage("showDueDates")
    static var  showDueDates : Bool = true
    @AppStorage("showPriorities")
    static var showPriorities : Bool = true
    @AppStorage("enableReminders")
    static var enableReminders: Bool = true
}
