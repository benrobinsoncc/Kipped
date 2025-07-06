import SwiftUI
import UIKit
import UserNotifications

enum AppIconOption: String, CaseIterable {
    case `default` = "AppIcon"
    case option1 = "AppIcon 1"
    case option2 = "AppIcon 2"
    case option3 = "AppIcon 3"
    case option4 = "AppIcon 4"
    case option5 = "AppIcon 5"
    case option6 = "AppIcon 6"
    case option7 = "AppIcon 7"
    case option8 = "AppIcon 8"
    
    var displayName: String {
        switch self {
        case .default: return "Default"
        case .option1: return "Style 1"
        case .option2: return "Style 2"
        case .option3: return "Style 3"
        case .option4: return "Style 4"
        case .option5: return "Style 5"
        case .option6: return "Style 6"
        case .option7: return "Style 7"
        case .option8: return "Style 8"
        }
    }
    
    var iconName: String {
        switch self {
        case .default: return "app"
        case .option1: return "app.fill"
        case .option2: return "app.badge"
        case .option3: return "app.badge.fill"
        case .option4: return "app.badge.checkmark"
        case .option5: return "app.badge.plus"
        case .option6: return "app.dashed"
        case .option7: return "app.gift"
        case .option8: return "app.connected.to.line.below"
        }
    }
    
    var color: Color {
        switch self {
        case .default: return .red
        case .option1: return .purple
        case .option2: return .orange
        case .option3: return .pink
        case .option4: return .green
        case .option5: return .red
        case .option6: return .blue
        case .option7: return .yellow
        case .option8: return .teal
        }
    }
    
    var imagePreviewName: String {
        switch self {
        case .default: return "AppIconPreview"
        case .option1: return "AppIconPreview1"
        case .option2: return "AppIconPreview2"
        case .option3: return "AppIconPreview3"
        case .option4: return "AppIconPreview4"
        case .option5: return "AppIconPreview5"
        case .option6: return "AppIconPreview6"
        case .option7: return "AppIconPreview7"
        case .option8: return "AppIconPreview8"
        }
    }
}

struct SettingsView: View {
    @Binding var appTheme: AppTheme
    @Binding var accentColor: Color
    @Binding var notificationsEnabled: Bool
    @Binding var hapticsEnabled: Bool
    var colorScheme: ColorScheme?
    @ObservedObject var todoViewModel: TodoViewModel
    @State private var selectedArchivedTodo: Todo? = nil
    @Binding var selectedAppIcon: AppIconOption
    @Binding var selectedFont: FontOption
    var onShowAccentSheet: (() -> Void)? = nil
    var onShowAppIconSheet: (() -> Void)? = nil
    var onShowThemeSheet: (() -> Void)? = nil
    var onShowFontSheet: (() -> Void)? = nil
    
    let accentColors: [(Color, String)] = [
        (Color(UIColor.systemBlue), "Blue"),
        (Color(UIColor.systemRed), "Red"),
        (Color(UIColor.systemGreen), "Green"),
        (Color(UIColor.systemOrange), "Orange"),
        (Color(UIColor.systemPurple), "Purple"),
        (Color(UIColor.systemPink), "Pink"),
        (Color(UIColor.systemTeal), "Teal"),
        (Color(UIColor.systemYellow), "Yellow")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // CUSTOMIZE Section
            VStack(alignment: .leading, spacing: 0) {
                Text("CUSTOMIZE")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 8)
                
                VStack(spacing: 0) {
                    // Theme Row
                    Button(action: {
                        HapticsManager.shared.impact(.soft)
                        onShowThemeSheet?()
                    }) {
                        HStack {
                            Image(systemName: "paintbrush")
                                .foregroundColor(.primary)
                            Text("Theme")
                                .appFont(selectedFont)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Accent Color Row
                    Button(action: { 
                        HapticsManager.shared.impact(.soft)
                        onShowAccentSheet?()
                    }) {
                        HStack {
                            Image(systemName: "paintpalette")
                                .foregroundColor(.primary)
                            Text("Accent Color")
                                .appFont(selectedFont)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // App Icon Row
                    Button(action: { 
                        HapticsManager.shared.impact(.soft)
                        onShowAppIconSheet?()
                    }) {
                        HStack {
                            Image(systemName: "app.badge")
                                .foregroundColor(.primary)
                            Text("App Icon")
                                .appFont(selectedFont)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Font Row
                    Button(action: { 
                        HapticsManager.shared.impact(.soft)
                        onShowFontSheet?()
                    }) {
                        HStack {
                            Image(systemName: "textformat")
                                .foregroundColor(.primary)
                            Text("Font")
                                .appFont(selectedFont)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .cornerRadius(10)
            }
            
            // NOTIFICATIONS & FEEDBACK Section
            VStack(alignment: .leading, spacing: 0) {
                Text("CONFIGURE")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 8)
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Notifications")
                            .appFont(selectedFont)
                            .foregroundColor(.primary)
                        Spacer()
                        SkeuomorphicToggle(isOn: $notificationsEnabled, accentColor: accentColor, onToggle: handleNotificationsToggle)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(UIColor.secondarySystemBackground))
                    
                    Divider()
                        .padding(.horizontal, 16)
                    
                    HStack {
                        Text("Haptics")
                            .appFont(selectedFont)
                            .foregroundColor(.primary)
                        Spacer()
                        SkeuomorphicToggle(isOn: $hapticsEnabled, accentColor: accentColor, isHapticsToggle: true)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(UIColor.secondarySystemBackground))
                }
                .cornerRadius(10)
            }
            
            // ARCHIVED TODOS Section
            VStack(alignment: .leading, spacing: 0) {
                Text("ARCHIVED TODOS")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 8)
                
                VStack(spacing: 0) {
                    if todoViewModel.archivedTodos.isEmpty {
                        HStack {
                            Text("No archived todos yet")
                                .appFont(selectedFont)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.secondarySystemBackground))
                    } else {
                        ForEach(todoViewModel.archivedTodos) { todo in
                            Button(action: { selectedArchivedTodo = todo }) {
                                HStack {
                                    Text(todo.title)
                                        .appFont(selectedFont)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(UIColor.secondarySystemBackground))
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .contextMenu {
                                Button(action: {
                                    HapticsManager.shared.impact(.soft)
                                    UIPasteboard.general.string = todo.title
                                }) {
                                    Text("Copy")
                                }
                            }
                        }
                    }
                }
                .cornerRadius(10)
            }
        }
        .padding(.top, 20)
        .sheet(item: $selectedArchivedTodo) { todo in
            AddTodoView(todoViewModel: todoViewModel, todoToEdit: todo, colorScheme: .constant(colorScheme ?? .dark), accentColor: $accentColor, selectedFont: $selectedFont, isArchivedMode: true) {
                todoViewModel.unarchiveTodo(todo)
                selectedArchivedTodo = nil
            }
        }
        .preferredColorScheme(colorScheme)
    }
    
    private func handleNotificationsToggle(_ enabled: Bool) {
        if enabled {
            // Request notification permission
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                DispatchQueue.main.async {
                    if !granted {
                        // If permission denied, revert toggle
                        notificationsEnabled = false
                    }
                    if let error = error {
                        print("Notification permission error: \(error)")
                        notificationsEnabled = false
                    }
                }
            }
        } else {
            // When turning off, we can't revoke permissions, but we can stop scheduling notifications
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }
}

struct SkeuomorphicToggle: View {
    @Binding var isOn: Bool
    let accentColor: Color
    let onToggle: ((Bool) -> Void)?
    let isHapticsToggle: Bool
    @State private var isPressed = false
    
    init(isOn: Binding<Bool>, accentColor: Color, onToggle: ((Bool) -> Void)? = nil, isHapticsToggle: Bool = false) {
        self._isOn = isOn
        self.accentColor = accentColor
        self.onToggle = onToggle
        self.isHapticsToggle = isHapticsToggle
    }
    
    private var toggleWidth: CGFloat { 52 }
    private var toggleHeight: CGFloat { 32 }
    private var knobSize: CGFloat { 26 }
    
    private var backgroundGradient: RadialGradient {
        if isOn {
            let uiColor = UIColor(accentColor)
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
            
            let brightColor = Color(
                red: min(1.0, r + 0.3),
                green: min(1.0, g + 0.3),
                blue: min(1.0, b + 0.3)
            )
            let darkColor = Color(
                red: max(0.0, r - 0.4),
                green: max(0.0, g - 0.4),
                blue: max(0.0, b - 0.4)
            )
            
            return RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: brightColor.opacity(0.95), location: 0.0),
                    .init(color: accentColor, location: 0.4),
                    .init(color: darkColor.opacity(0.8), location: 0.8),
                    .init(color: darkColor.opacity(0.9), location: 1.0)
                ]),
                center: UnitPoint(x: 0.3, y: 0.3),
                startRadius: 0,
                endRadius: toggleWidth * 0.6
            )
        } else {
            return RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.85, green: 0.85, blue: 0.87), location: 0.0),
                    .init(color: Color(red: 0.75, green: 0.75, blue: 0.77), location: 0.4),
                    .init(color: Color(red: 0.65, green: 0.65, blue: 0.67), location: 0.8),
                    .init(color: Color(red: 0.55, green: 0.55, blue: 0.57), location: 1.0)
                ]),
                center: UnitPoint(x: 0.3, y: 0.3),
                startRadius: 0,
                endRadius: toggleWidth * 0.6
            )
        }
    }
    
    private var knobGradient: RadialGradient {
        RadialGradient(
            gradient: Gradient(stops: [
                .init(color: Color.white.opacity(0.95), location: 0.0),
                .init(color: Color(red: 0.95, green: 0.95, blue: 0.97), location: 0.4),
                .init(color: Color(red: 0.85, green: 0.85, blue: 0.87), location: 0.8),
                .init(color: Color(red: 0.75, green: 0.75, blue: 0.77), location: 1.0)
            ]),
            center: UnitPoint(x: 0.3, y: 0.3),
            startRadius: 0,
            endRadius: knobSize * 0.6
        )
    }
    
    var body: some View {
        Button(action: {
            let newValue = !isOn
            
            if isHapticsToggle {
                // For haptics toggle: provide direct feedback when turning ON (since HapticsManager would be disabled)
                // No feedback when turning OFF (as expected)
                if newValue == true {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
            } else {
                // For other toggles: always use HapticsManager (respects user setting)
                HapticsManager.shared.impact(.soft)
            }
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isOn = newValue
            }
            onToggle?(newValue)
        }) {
            ZStack {
                // Background track
                RoundedRectangle(cornerRadius: toggleHeight / 2)
                    .fill(backgroundGradient)
                    .frame(width: toggleWidth, height: toggleHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: toggleHeight / 2)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color.white.opacity(0.4), location: 0.0),
                                        .init(color: Color.clear, location: 0.15),
                                        .init(color: Color.clear, location: 0.85),
                                        .init(color: Color.black.opacity(0.4), location: 1.0)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .overlay(
                        // Inner rim
                        RoundedRectangle(cornerRadius: toggleHeight / 2)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color.white.opacity(0.9), location: 0.0),
                                        .init(color: Color.white.opacity(0.3), location: 0.3),
                                        .init(color: Color.clear, location: 0.7),
                                        .init(color: Color.black.opacity(0.5), location: 1.0)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                            .frame(width: toggleWidth - 2, height: toggleHeight - 2)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .shadow(color: isOn ? accentColor.opacity(0.3) : Color.clear, radius: 6, x: 0, y: 3)
                
                // Knob
                Circle()
                    .fill(knobGradient)
                    .frame(width: knobSize, height: knobSize)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color.white.opacity(0.8), location: 0.0),
                                        .init(color: Color.clear, location: 0.15),
                                        .init(color: Color.clear, location: 0.85),
                                        .init(color: Color.black.opacity(0.3), location: 1.0)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .overlay(
                        // Gloss overlay
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color.white.opacity(0.8), location: 0.0),
                                        .init(color: Color.white.opacity(0.3), location: 0.3),
                                        .init(color: Color.clear, location: 0.7),
                                        .init(color: Color.clear, location: 1.0)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: knobSize * 0.7, height: knobSize * 0.7)
                            .offset(x: -knobSize * 0.1, y: -knobSize * 0.1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .offset(x: isOn ? (toggleWidth - knobSize) / 2 - 3 : -(toggleWidth - knobSize) / 2 + 3)
                    .scaleEffect(isPressed ? 0.92 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isOn)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.12)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// UIKit blur wrapper for strong overlay effect
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: effect)
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
} 