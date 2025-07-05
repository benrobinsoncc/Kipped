//
//  Todo.swift
//  Kipped
//
//  Created by Ben Robinson on 28/06/2025.
//

import Foundation

struct Todo: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var isCompleted: Bool = false
    var isArchived: Bool = false
    var createdAt = Date()
    var reminderDate: Date? = nil
} 