import SwiftUI

// MARK: - View State Management Protocols
protocol ViewStateManaging: ObservableObject {
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }
}

// MARK: - Theme Management Protocols
protocol ThemeProviding {
    var currentColorScheme: ColorScheme? { get }
    var accentColor: Color { get }
    var selectedFont: FontOption { get }
    var tintedBackgrounds: Bool { get }
}

// MARK: - Data Persistence Protocols
protocol DataPersisting {
    func save()
    func load()
}

// MARK: - Navigation Protocols
protocol NavigationManaging {
    associatedtype Route
    var currentRoute: Route? { get set }
    func navigate(to route: Route)
    func goBack()
}

// MARK: - Haptics Management Protocol
protocol HapticsProviding {
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle)
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType)
    func selection()
}

// MARK: - Default Implementations
extension HapticsProviding {
    func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}