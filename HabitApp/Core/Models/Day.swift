//
//  Day.swift
//  HabitApp
//
//  Created by Aula03 on 22/10/25.
//

import Foundation

struct Day : Hashable, Equatable, Codable {
    static let calendar = Calendar.current
    let day : DayOfMonth
    let month : MonthOfYear
    let year : Year
    
    /// This is now a COMPUTED property, not a stored property.
    /// Codable will ignore it, which is correct.
    /// It's optional because components might form an invalid date (e.g., Feb 30).
    var date: Date? {
        let components = DateComponents(year: year.value, month: month.value, day: day.value)
        return Self.calendar.date(from: components)
    }
     
    // MARK: - Nested Types
    
    struct DayOfMonth : Hashable, Codable {
        let value: Int

        init?(_ value: Int) {
            guard (1...31).contains(value) else { return nil }
            self.value = value
        }
        
        // --- Codable Conformance ---
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let intValue = try container.decode(Int.self)
            guard let validSelf = Self.init(intValue) else {
                throw DecodingError.dataCorruptedError(in: container,
                                                       debugDescription: "Invalid DayOfMonth value: \(intValue)")
            }
            self = validSelf
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.value)
        }
    }

    struct MonthOfYear : Hashable, Codable {
        let value: Int

        init?(_ value: Int) {
            guard (1...12).contains(value) else { return nil }
            self.value = value
        }
        
        // --- Codable Conformance ---
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let intValue = try container.decode(Int.self)
            guard let validSelf = Self.init(intValue) else {
                throw DecodingError.dataCorruptedError(in: container,
                                                       debugDescription: "Invalid MonthOfYear value: \(intValue)")
            }
            self = validSelf
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.value)
        }
    }

    struct Year : Hashable, Codable {
        let value: Int

        init(_ value: Int) {
            self.value = value
        }
        
        // --- Codable Conformance ---
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let intValue = try container.decode(Int.self)
            self.init(intValue) // Use the standard init
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.value)
        }
    }
}
