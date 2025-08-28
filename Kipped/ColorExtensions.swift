//
//  ColorExtensions.swift
//  Kipped
//
//  Created by Assistant on 14/07/2025.
//

import SwiftUI

extension Color {
    init?(hex: String) {
        let r, g, b: Double
        var hexColor = hex
        
        // Remove # if present
        if hexColor.hasPrefix("#") {
            hexColor.remove(at: hexColor.startIndex)
        }
        
        // Handle 3 or 6 character hex
        if hexColor.count == 3 {
            // Convert 3-char hex to 6-char
            hexColor = hexColor.map { "\($0)\($0)" }.joined()
        }
        
        guard hexColor.count == 6,
              let hexNumber = Int(hexColor, radix: 16) else {
            return nil
        }
        
        r = Double((hexNumber & 0xff0000) >> 16) / 255
        g = Double((hexNumber & 0x00ff00) >> 8) / 255
        b = Double(hexNumber & 0x0000ff) / 255
        
        self.init(red: r, green: g, blue: b)
    }
}