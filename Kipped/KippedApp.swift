//
//  KippedApp.swift
//  Kipped
//
//  Created by Ben Robinson on 28/06/2025.
//

import SwiftUI
import UserNotifications

@main
struct KippedApp: App {
    @State private var appTheme: AppTheme = KippedApp.loadTheme()
    @State private var accentColor: Color = KippedApp.loadAccentColor()
    @State private var notificationsEnabled: Bool = true

    private var colorScheme: ColorScheme? {
        switch appTheme {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(appTheme: $appTheme, accentColor: $accentColor, notificationsEnabled: $notificationsEnabled)
                .preferredColorScheme(colorScheme)
                .accentColor(accentColor)
                .onChange(of: appTheme) { newTheme in
                    KippedApp.saveTheme(newTheme)
                }
                .onChange(of: accentColor) { newColor in
                    KippedApp.saveAccentColor(newColor)
                }
        }
    }

    // MARK: - Persistence for Theme
    private static let themeKey = "app_theme"
    private static let accentColorKey = "accent_color"

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
        if let data = UserDefaults.standard.data(forKey: accentColorKey), let uiColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor {
            let color = Color(uiColor)
            // Validate that the color isn't black (which indicates a conversion failure)
            let testUIColor = UIColor(color)
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            testUIColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            // If it's pure black, it's likely a conversion error, so reset
            if red == 0 && green == 0 && blue == 0 {
                UserDefaults.standard.removeObject(forKey: accentColorKey)
                return Color(UIColor.systemBlue)
            }
            
            return color
        }
        return Color(UIColor.systemBlue)
    }
}