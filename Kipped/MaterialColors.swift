import SwiftUI

extension Color {
    // MARK: - Selected Classic Materials
    static let materialRoseGold = Color(red: 0.91, green: 0.71, blue: 0.66)
    static let materialSlate = Color(red: 0.44, green: 0.50, blue: 0.56)
    static let materialSapphire = Color(red: 0.06, green: 0.32, blue: 0.73)
    static let materialAmethyst = Color(red: 0.60, green: 0.40, blue: 0.80)
    
    // MARK: - Enhanced Textured Materials
    static let materialBrushedSteel = Color(red: 0.68, green: 0.70, blue: 0.72)
    static let materialPatinaBronze = Color(red: 0.50, green: 0.42, blue: 0.30)
    static let materialCarbonFiber = Color(red: 0.15, green: 0.15, blue: 0.15)
    static let materialAnodizedTitanium = Color(red: 0.55, green: 0.58, blue: 0.62)
    
    static let materialDistressedLeather = Color(red: 0.40, green: 0.25, blue: 0.15)
    static let materialWornDenim = Color(red: 0.25, green: 0.35, blue: 0.55)
    static let materialVelvet = Color(red: 0.45, green: 0.20, blue: 0.35)
    static let materialCanvas = Color(red: 0.85, green: 0.82, blue: 0.75)
    
    static let materialPrismatic = Color(red: 0.85, green: 0.85, blue: 0.95)
    static let materialOpalescent = Color(red: 0.90, green: 0.88, blue: 0.92)
    static let materialHolographic = Color(red: 0.75, green: 0.80, blue: 0.90)
    static let materialIridescent = Color(red: 0.60, green: 0.70, blue: 0.85)
    
    // Helper for rainbow colors
    static func rainbow(at position: Double) -> Color {
        let hue = position.truncatingRemainder(dividingBy: 1.0)
        return Color(hue: hue, saturation: 0.8, brightness: 0.9)
    }
    
    // Helper for tinted backgrounds
    static func tintedBackground(accentColor: Color, isEnabled: Bool, colorScheme: ColorScheme?) -> Color {
        guard isEnabled else { return Color(UIColor.systemBackground) }
        
        let uiColor = UIColor(accentColor)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let tintStrength: CGFloat = colorScheme == .dark ? 0.08 : 0.03
        
        if colorScheme == .dark {
            return Color(
                red: 0.05 + (r * tintStrength),
                green: 0.05 + (g * tintStrength),
                blue: 0.05 + (b * tintStrength)
            )
        } else {
            return Color(
                red: 0.98 + (r * tintStrength * 0.5),
                green: 0.98 + (g * tintStrength * 0.5),
                blue: 0.98 + (b * tintStrength * 0.5)
            )
        }
    }
    
    static func tintedSecondaryBackground(accentColor: Color, isEnabled: Bool, colorScheme: ColorScheme?) -> Color {
        guard isEnabled else { return Color(UIColor.secondarySystemBackground) }
        
        let uiColor = UIColor(accentColor)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let tintStrength: CGFloat = colorScheme == .dark ? 0.12 : 0.05
        
        if colorScheme == .dark {
            return Color(
                red: 0.1 + (r * tintStrength),
                green: 0.1 + (g * tintStrength),
                blue: 0.1 + (b * tintStrength)
            )
        } else {
            return Color(
                red: 0.94 + (r * tintStrength * 0.5),
                green: 0.94 + (g * tintStrength * 0.5),
                blue: 0.94 + (b * tintStrength * 0.5)
            )
        }
    }
}

// MARK: - Material Types
enum MaterialType {
    case solid
    case metallic
    case stone
    case gemstone
    case brushedMetal
    case patinaMetal
    case carbonFiber
    case anodized
    case leather
    case fabric
    case velvet
    case canvas
    case prismatic
    case opalescent
    case holographic
    case iridescent
}

// MARK: - Material Color Info
struct MaterialColorInfo {
    let name: String
    let color: Color
    let type: MaterialType
}

// MARK: - Material Color Categories
struct MaterialColorCategory {
    let name: String
    let colors: [MaterialColorInfo]
}

extension MaterialColorCategory {
    static let allCategories = [
        MaterialColorCategory(
            name: "System",
            colors: [
                MaterialColorInfo(name: "Blue", color: Color(UIColor.systemBlue), type: .solid),
                MaterialColorInfo(name: "Red", color: Color(UIColor.systemRed), type: .solid),
                MaterialColorInfo(name: "Green", color: Color(UIColor.systemGreen), type: .solid),
                MaterialColorInfo(name: "Orange", color: Color(UIColor.systemOrange), type: .solid),
                MaterialColorInfo(name: "Purple", color: Color(UIColor.systemPurple), type: .solid),
                MaterialColorInfo(name: "Pink", color: Color(UIColor.systemPink), type: .solid),
                MaterialColorInfo(name: "Teal", color: Color(UIColor.systemTeal), type: .solid),
                MaterialColorInfo(name: "Yellow", color: Color(UIColor.systemYellow), type: .solid)
            ]
        ),
        MaterialColorCategory(
            name: "Classic",
            colors: [
                MaterialColorInfo(name: "Rose Gold", color: Color.materialRoseGold, type: .metallic),
                MaterialColorInfo(name: "Slate", color: Color.materialSlate, type: .stone),
                MaterialColorInfo(name: "Sapphire", color: Color.materialSapphire, type: .gemstone),
                MaterialColorInfo(name: "Amethyst", color: Color.materialAmethyst, type: .gemstone)
            ]
        ),
        MaterialColorCategory(
            name: "Metals",
            colors: [
                MaterialColorInfo(name: "Brushed Steel", color: Color.materialBrushedSteel, type: .brushedMetal),
                MaterialColorInfo(name: "Patina Bronze", color: Color.materialPatinaBronze, type: .patinaMetal),
                MaterialColorInfo(name: "Carbon Fiber", color: Color.materialCarbonFiber, type: .carbonFiber),
                MaterialColorInfo(name: "Anodized Titanium", color: Color.materialAnodizedTitanium, type: .anodized)
            ]
        ),
        MaterialColorCategory(
            name: "Textiles",
            colors: [
                MaterialColorInfo(name: "Distressed Leather", color: Color.materialDistressedLeather, type: .leather),
                MaterialColorInfo(name: "Worn Denim", color: Color.materialWornDenim, type: .fabric),
                MaterialColorInfo(name: "Velvet", color: Color.materialVelvet, type: .velvet),
                MaterialColorInfo(name: "Canvas", color: Color.materialCanvas, type: .canvas)
            ]
        ),
        MaterialColorCategory(
            name: "Luminous",
            colors: [
                MaterialColorInfo(name: "Prismatic", color: Color.materialPrismatic, type: .prismatic),
                MaterialColorInfo(name: "Opalescent", color: Color.materialOpalescent, type: .opalescent),
                MaterialColorInfo(name: "Holographic", color: Color.materialHolographic, type: .holographic),
                MaterialColorInfo(name: "Iridescent", color: Color.materialIridescent, type: .iridescent)
            ]
        )
    ]
    
    static var allColors: [(name: String, color: Color)] {
        allCategories.flatMap { category in
            category.colors.map { ($0.name, $0.color) }
        }
    }
}