//
//  Day.swift
//  HabitApp
//
//  Created by Aula03 on 22/10/25.
//

import Foundation

struct Day : Hashable, Equatable {
    static let calendar = Calendar.current
    let day : DayOfMonth
    let month : MonthOfYear
    let year : Year
    let date: Date = Date()
    
    struct DayOfMonth : Hashable {
        let value: Int

        init?(_ value: Int) {
            guard (1...31).contains(value) else { return nil }
            self.value = value
        }
    }

    struct MonthOfYear : Hashable {
        let value: Int

        init?(_ value: Int) {
            guard (1...12).contains(value) else { return nil }
            self.value = value
        }
    }

    struct Year : Hashable {
        let value: Int

        init(_ value: Int) {
            self.value = value
        }
    }
}
