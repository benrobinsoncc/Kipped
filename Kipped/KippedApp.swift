//
//  KippedApp.swift
//  Kipped
//
//  Created by Ben Robinson on 28/06/2025.
//

import SwiftUI
import UserNotifications

enum FontOption: String, CaseIterable {
    case system = "system"
    case rounded = "rounded"
    case monospaced = "monospaced"
    case serif = "serif"
    case large = "large"
    case bold = "bold"
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .rounded: return "Rounded"
        case .monospaced: return "Code"
        case .serif: return "Serif"
        case .large: return "Large"
        case .bold: return "Bold"
        }
    }
    
    var font: Font {
        switch self {
        case .system: return .system(.body)
        case .rounded: return .system(.body, design: .rounded)
        case .monospaced: return .system(.body, design: .monospaced)
        case .serif: return .system(.body, design: .serif)
        case .large: return .system(.title3, weight: .medium)
        case .bold: return .system(.body, weight: .heavy)
        }
    }
    
    var uiFont: UIFont {
        switch self {
        case .system: return UIFont.systemFont(ofSize: 17)
        case .rounded: return UIFont.systemFont(ofSize: 17, weight: .regular)
        case .monospaced: return UIFont.monospacedSystemFont(ofSize: 17, weight: .regular)
        case .serif: return UIFont.systemFont(ofSize: 17)
        case .large: return UIFont.systemFont(ofSize: 20, weight: .medium)
        case .bold: return UIFont.systemFont(ofSize: 17, weight: .heavy)
        }
    }
}


class HapticsManager {
    static let shared = HapticsManager()
    
    private init() {}
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard KippedApp.loadHapticsEnabled() else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard KippedApp.loadHapticsEnabled() else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}

@main
struct KippedApp: App {
    @State private var appTheme: AppTheme = KippedApp.loadTheme()
    @State private var accentColor: Color = KippedApp.loadAccentColor()
    @State private var notificationsEnabled: Bool = KippedApp.loadNotificationsEnabled()
    @State private var hapticsEnabled: Bool = KippedApp.loadHapticsEnabled()
    @State private var selectedFont: FontOption = KippedApp.loadFont()
    @State private var tintedBackgrounds: Bool = KippedApp.loadTintedBackgrounds()

    private var colorScheme: ColorScheme? {
        switch appTheme {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    init() {
        // Initialize NotificationManager to set up delegate
        _ = NotificationManager.shared
        
        // Check notification status on app launch
        NotificationManager.shared.checkNotificationStatus { authorized in
            if authorized && UserDefaults.standard.bool(forKey: "notifications_enabled") {
                // If notifications are authorized and enabled, ensure daily notification is scheduled
                let notificationTime = NotificationManager.shared.loadNotificationTime()
                NotificationManager.shared.scheduleDailyNotification(at: notificationTime)
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(appTheme: $appTheme, accentColor: $accentColor, notificationsEnabled: $notificationsEnabled, hapticsEnabled: $hapticsEnabled, selectedFont: $selectedFont, tintedBackgrounds: $tintedBackgrounds)
                .preferredColorScheme(colorScheme)
                .accentColor(accentColor)
                .onChange(of: appTheme) { newTheme in
                    KippedApp.saveTheme(newTheme)
                }
                .onChange(of: accentColor) { newColor in
                    KippedApp.saveAccentColor(newColor)
                }
                .onChange(of: hapticsEnabled) { newValue in
                    KippedApp.saveHapticsEnabled(newValue)
                }
                .onChange(of: selectedFont) { newFont in
                    KippedApp.saveFont(newFont)
                }
                .onChange(of: tintedBackgrounds) { newValue in
                    KippedApp.saveTintedBackgrounds(newValue)
                }
                .onChange(of: notificationsEnabled) { newValue in
                    KippedApp.saveNotificationsEnabled(newValue)
                }
        }
    }

    // MARK: - Persistence for Theme
    private static let themeKey = "app_theme"
    private static let accentColorKey = "accent_color"
    private static let hapticsEnabledKey = "haptics_enabled"
    private static let fontKey = "selected_font"
    private static let tintedBackgroundsKey = "tinted_backgrounds"
    private static let notificationsEnabledKey = "notifications_enabled"

    static func saveTheme(_ theme: AppTheme) {
        UserDefaults.standard.set(theme.rawValue, forKey: themeKey)
    }

    static func loadTheme() -> AppTheme {
        if let raw = UserDefaults.standard.string(forKey: themeKey), let theme = AppTheme(rawValue: raw) {
            return theme
        }
        return .system
    }

    static func saveAccentColor(_ color: Color) {
        let uiColor = UIColor(color)
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false) {
            UserDefaults.standard.set(data, forKey: accentColorKey)
        }
    }

    static func loadAccentColor() -> Color {
        let allColors = MaterialColorCategory.allColors.map { $0.color }
        
        if let data = UserDefaults.standard.data(forKey: accentColorKey), let uiColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor {
            let loadedColor = Color(uiColor)
            
            // Validate that the color isn't black (which indicates a conversion failure)
            let testUIColor = UIColor(loadedColor)
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            testUIColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            // If it's pure black, it's likely a conversion error, so reset
            if red == 0 && green == 0 && blue == 0 {
                UserDefaults.standard.removeObject(forKey: accentColorKey)
                return Color(UIColor.systemBlue)
            }
            
            // Find the closest matching color from all available colors
            var closestColor = allColors[0]
            var smallestDistance = CGFloat.greatestFiniteMagnitude
            
            for availableColor in allColors {
                let availableUIColor = UIColor(availableColor)
                var availR: CGFloat = 0, availG: CGFloat = 0, availB: CGFloat = 0, availA: CGFloat = 0
                availableUIColor.getRed(&availR, green: &availG, blue: &availB, alpha: &availA)
                
                // Calculate color distance
                let distance = sqrt(pow(red - availR, 2) + pow(green - availG, 2) + pow(blue - availB, 2))
                if distance < smallestDistance {
                    smallestDistance = distance
                    closestColor = availableColor
                }
            }
            
            // If very close to an available color, use the exact color
            if smallestDistance < 0.1 {
                return closestColor
            }
            
            return loadedColor
        }
        return Color(UIColor.systemBlue)
    }
    
    static func saveHapticsEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: hapticsEnabledKey)
    }
    
    static func loadHapticsEnabled() -> Bool {
        if UserDefaults.standard.object(forKey: hapticsEnabledKey) != nil {
            return UserDefaults.standard.bool(forKey: hapticsEnabledKey)
        }
        return true // Default to enabled
    }
    
    static func saveFont(_ font: FontOption) {
        UserDefaults.standard.set(font.rawValue, forKey: fontKey)
    }
    
    static func loadFont() -> FontOption {
        if let raw = UserDefaults.standard.string(forKey: fontKey), let font = FontOption(rawValue: raw) {
            return font
        }
        return .system
    }
    
    static func saveTintedBackgrounds(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: tintedBackgroundsKey)
    }
    
    static func loadTintedBackgrounds() -> Bool {
        if UserDefaults.standard.object(forKey: tintedBackgroundsKey) != nil {
            return UserDefaults.standard.bool(forKey: tintedBackgroundsKey)
        }
        return false // Default to disabled
    }
    
    static func saveNotificationsEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: notificationsEnabledKey)
    }
    
    static func loadNotificationsEnabled() -> Bool {
        if UserDefaults.standard.object(forKey: notificationsEnabledKey) != nil {
            return UserDefaults.standard.bool(forKey: notificationsEnabledKey)
        }
        return false // Default to disabled
    }
}