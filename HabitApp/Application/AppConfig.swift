//
//  AppConfig.swift
//  HabitApp
//
//  Created by Aula03 on 15/10/25.
//

import SwiftUI
import Combine

class AppConfig: ObservableObject  {
    @AppStorage("showDueDates")
    static var  showDueDates : Bool = true
    @AppStorage("showPriorities")
    static var showPriorities : Bool = true
    @AppStorage("enableReminders")
    static var enableReminders: Bool = true

    
}
