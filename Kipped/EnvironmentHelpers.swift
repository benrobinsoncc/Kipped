import SwiftUI

// MARK: - Environment Keys
struct CurrentColorSchemeKey: EnvironmentKey {
    static let defaultValue: ColorScheme? = nil
}

struct AccentColorKey: EnvironmentKey {
    static let defaultValue: Color = .blue
}

struct SelectedFontKey: EnvironmentKey {
    static let defaultValue: FontOption = .system
}

struct TintedBackgroundsKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

// MARK: - Environment Values Extension
extension EnvironmentValues {
    var currentColorScheme: ColorScheme? {
        get { self[CurrentColorSchemeKey.self] }
        set { self[CurrentColorSchemeKey.self] = newValue }
    }
    
    var appAccentColor: Color {
        get { self[AccentColorKey.self] }
        set { self[AccentColorKey.self] = newValue }
    }
    
    var appSelectedFont: FontOption {
        get { self[SelectedFontKey.self] }
        set { self[SelectedFontKey.self] = newValue }
    }
    
    var appTintedBackgrounds: Bool {
        get { self[TintedBackgroundsKey.self] }
        set { self[TintedBackgroundsKey.self] = newValue }
    }
}

// MARK: - View Extensions
extension View {
    func appEnvironment(
        colorScheme: ColorScheme?,
        accentColor: Color,
        selectedFont: FontOption,
        tintedBackgrounds: Bool
    ) -> some View {
        self.environment(\.currentColorScheme, colorScheme)
            .environment(\.appAccentColor, accentColor)
            .environment(\.appSelectedFont, selectedFont)
            .environment(\.appTintedBackgrounds, tintedBackgrounds)
    }
}