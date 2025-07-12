//
//  ViewMode.swift
//  Kipped
//
//  Created by Ben Robinson on 28/06/2025.
//

import Foundation

enum ViewMode: String, CaseIterable {
    case year = "Year"
    case month = "Month"
    case week = "Week"
    
    var displayName: String {
        return self.rawValue
    }
}