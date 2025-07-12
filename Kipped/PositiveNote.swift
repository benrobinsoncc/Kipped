//
//  PositiveNote.swift
//  Kipped
//
//  Created by Ben Robinson on 28/06/2025.
//

import Foundation

struct PositiveNote: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var content: String
    var date: Date
    var createdAt: Date = Date()
    
    // Helper to get just the date portion (no time)
    var dayDate: Date {
        Calendar.current.startOfDay(for: date)
    }
    
    // Helper to check if this note is for today
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    // Helper to format the date for display
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// Extension to help with date comparisons
extension PositiveNote {
    static func == (lhs: PositiveNote, rhs: PositiveNote) -> Bool {
        lhs.id == rhs.id
    }
}