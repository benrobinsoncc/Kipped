import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var currentTheme: AppTheme = .system
    @Published var currentAccentColor: Color = Color.blue
    @Published var isNotificationsEnabled: Bool = true
    @Published var isHapticsEnabled: Bool = true
    @Published var selectedFont: FontOption = .system
    @Published var tintedBackgrounds: Bool = false
    
    init() {
        loadSettings()
    }
    
    private func loadSettings() {
        currentTheme = KippedApp.loadTheme()
        currentAccentColor = KippedApp.loadAccentColor()
        isHapticsEnabled = KippedApp.loadHapticsEnabled()
        selectedFont = KippedApp.loadFont()
        tintedBackgrounds = KippedApp.loadTintedBackgrounds()
    }
    
    func saveSettings() {
        KippedApp.saveTheme(currentTheme)
        KippedApp.saveAccentColor(currentAccentColor)
        KippedApp.saveHapticsEnabled(isHapticsEnabled)
        KippedApp.saveFont(selectedFont)
        KippedApp.saveTintedBackgrounds(tintedBackgrounds)
    }
}