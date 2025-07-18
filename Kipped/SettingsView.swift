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
        case .option5: return "plus.app"
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
    @Binding var selectedAppIcon: AppIconOption
    @Binding var selectedFont: FontOption
    @Binding var tintedBackgrounds: Bool
    @ObservedObject var viewModel: PositiveNoteViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingThemeSheet = false
    @State private var showingAccentSheet = false
    @State private var showingAppIconSheet = false
    @State private var showingFontSheet = false
    @State private var notificationTime = NotificationManager.shared.loadNotificationTime()
    @State private var showingTimePicker = false
    @State private var showingShareSheet = false
    @State private var shareImage: UIImage?
    @State private var isGeneratingImage = false
    
    let accentColors: [(Color, String)] = MaterialColorCategory.allCategories.first?.colors.map { ($0.color, $0.name) } ?? []
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    private var tintedBackground: Color {
        Color.tintedBackground(accentColor: accentColor, isEnabled: tintedBackgrounds, colorScheme: colorScheme)
    }
    
    private var tintedSecondaryBackground: Color {
        Color.tintedSecondaryBackground(accentColor: accentColor, isEnabled: tintedBackgrounds, colorScheme: colorScheme)
    }
    
    var body: some View {
        ZStack {
            tintedBackground
                .ignoresSafeArea()
            
            NavigationView {
                List {
                    Section("Customize") {
                        Button(action: {
                            HapticsManager.shared.impact(.soft)
                            showingThemeSheet = true
                        }) {
                            HStack {
                                Image(systemName: "paintbrush")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Text("Theme")
                                    .appFont(selectedFont)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                        .listRowBackground(tintedSecondaryBackground)
                        
                        Button(action: {
                            HapticsManager.shared.impact(.soft)
                            showingAccentSheet = true
                        }) {
                            HStack {
                                Image(systemName: "paintpalette")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Text("Accent colour")
                                    .appFont(selectedFont)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                        .listRowBackground(tintedSecondaryBackground)
                        
                        Button(action: {
                            HapticsManager.shared.impact(.soft)
                            showingAppIconSheet = true
                        }) {
                            HStack {
                                Image(systemName: "app.badge")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Text("App icon")
                                    .appFont(selectedFont)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                        .listRowBackground(tintedSecondaryBackground)
                        
                        Button(action: {
                            HapticsManager.shared.impact(.soft)
                            showingFontSheet = true
                        }) {
                            HStack {
                                Image(systemName: "textformat")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Text("Font")
                                    .appFont(selectedFont)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                        .listRowBackground(tintedSecondaryBackground)
                    }
                    
                    Section("Configure") {
                        HStack {
                            Image(systemName: "hand.tap")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Text("Haptics")
                                .appFont(selectedFont)
                                .foregroundColor(.primary)
                            Spacer()
                            SkeuomorphicToggle(isOn: $hapticsEnabled, accentColor: accentColor, isHapticsToggle: true)
                        }
                        .listRowBackground(tintedSecondaryBackground)
                        
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Text("Notifications")
                                .appFont(selectedFont)
                                .foregroundColor(.primary)
                            Spacer()
                            SkeuomorphicToggle(isOn: $notificationsEnabled, accentColor: accentColor, onToggle: handleNotificationsToggle)
                        }
                        .listRowBackground(tintedSecondaryBackground)
                        
                        if notificationsEnabled {
                            Button(action: {
                                HapticsManager.shared.impact(.soft)
                                showingTimePicker = true
                            }) {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                    Text("Daily prompt time")
                                        .appFont(selectedFont)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(timeFormatter.string(from: notificationTime))
                                        .appFont(selectedFont)
                                        .foregroundColor(.secondary)
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                            }
                            .listRowBackground(tintedSecondaryBackground)
                        }
                    }
                    
                    Section("Share") {
                        Button(action: {
                            shareYearView()
                        }) {
                            HStack {
                                if isGeneratingImage {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(0.7)
                                } else {
                                    Image(systemName: "square.and.arrow.up")
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                }
                                Text("Share year progress")
                                    .appFont(selectedFont)
                                    .foregroundColor(.primary)
                                Spacer()
                                if !isGeneratingImage {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                            }
                        }
                        .disabled(isGeneratingImage)
                        .listRowBackground(tintedSecondaryBackground)
                    }
                    
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.secondary.opacity(0.15))
                                    .frame(width: 28, height: 28)
                                
                                Image(systemName: "xmark")
                                    .foregroundColor(.secondary.opacity(0.7))
                                    .font(.system(size: 11, weight: .bold))
                            }
                        }
                    }
                }
            }
            
            
        }
        .sheet(isPresented: $showingThemeSheet) {
            ThemePickerContent(
                appTheme: $appTheme,
                onThemeSelected: { theme in
                    appTheme = theme
                },
                accentColor: accentColor,
                tintedBackgrounds: tintedBackgrounds,
                currentColorScheme: colorScheme
            )
            .presentationDetents([.fraction(0.20)])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showingAccentSheet) {
            AccentColorPickerContent(
                accentColor: $accentColor,
                tintedBackgrounds: $tintedBackgrounds,
                colors: accentColors,
                onColorSelected: { color in
                    accentColor = color
                },
                currentColorScheme: colorScheme
            )
            .presentationDetents([.fraction(0.60)])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showingAppIconSheet) {
            AppIconSelectionContent(
                selectedAppIcon: $selectedAppIcon,
                onIconSelected: { icon in
                    selectedAppIcon = icon
                },
                accentColor: accentColor,
                tintedBackgrounds: tintedBackgrounds,
                currentColorScheme: colorScheme
            )
            .presentationDetents([.fraction(0.50)])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showingFontSheet) {
            FontPickerContent(
                selectedFont: $selectedFont,
                onFontSelected: { font in
                    selectedFont = font
                },
                accentColor: accentColor,
                tintedBackgrounds: tintedBackgrounds,
                currentColorScheme: colorScheme
            )
            .presentationDetents([.fraction(0.25)])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showingTimePicker) {
            NotificationTimePickerContent(
                notificationTime: $notificationTime,
                onTimeSelected: { time in
                    notificationTime = time
                    NotificationManager.shared.scheduleDailyNotification(at: time)
                },
                accentColor: accentColor,
                tintedBackgrounds: tintedBackgrounds,
                currentColorScheme: colorScheme,
                selectedFont: selectedFont
            )
            .presentationDetents([.fraction(0.3)])
        }
        .sheet(isPresented: $showingShareSheet) {
            if let image = shareImage {
                ActivityViewController(activityItems: [image])
            }
        }
        .preferredColorScheme(colorScheme)
    }
    
    @MainActor
    private func shareYearView() {
        isGeneratingImage = true
        
        Task { @MainActor in
            shareImage = YearViewExporter.exportYearView(
                viewModel: viewModel,
                accentColor: accentColor,
                selectedFont: selectedFont,
                tintedBackgrounds: tintedBackgrounds,
                colorScheme: colorScheme
            )
            
            isGeneratingImage = false
            
            if shareImage != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showingShareSheet = true
                }
            }
        }
    }
    
    private func handleNotificationsToggle(_ enabled: Bool) {
        if enabled {
            // Request notification permission
            NotificationManager.shared.requestNotificationPermissions { granted in
                if granted {
                    // Schedule notification at the saved time
                    NotificationManager.shared.scheduleDailyNotification(at: notificationTime)
                } else {
                    // If permission denied, revert toggle
                    notificationsEnabled = false
                }
            }
        } else {
            // When turning off, cancel notifications
            NotificationManager.shared.cancelDailyNotification()
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
                // Background track with material texture
                RoundedRectangle(cornerRadius: toggleHeight / 2)
                    .fill(backgroundGradient)
                    .frame(width: toggleWidth, height: toggleHeight)
                    .materialStyle(accentColor: isOn ? accentColor : .gray)
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

struct NotificationTimePickerContent: View {
    @Binding var notificationTime: Date
    let onTimeSelected: (Date) -> Void
    let accentColor: Color
    let tintedBackgrounds: Bool
    var currentColorScheme: ColorScheme?
    let selectedFont: FontOption
    @State private var tempTime: Date
    @Environment(\.dismiss) private var dismiss
    
    init(notificationTime: Binding<Date>, onTimeSelected: @escaping (Date) -> Void, accentColor: Color, tintedBackgrounds: Bool, currentColorScheme: ColorScheme?, selectedFont: FontOption) {
        self._notificationTime = notificationTime
        self.onTimeSelected = onTimeSelected
        self.accentColor = accentColor
        self.tintedBackgrounds = tintedBackgrounds
        self.currentColorScheme = currentColorScheme
        self.selectedFont = selectedFont
        self._tempTime = State(initialValue: notificationTime.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("", selection: $tempTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .frame(height: 200)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Select time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onTimeSelected(tempTime)
                        dismiss()
                    }
                    .appFont(selectedFont)
                }
            }
        }
        .preferredColorScheme(currentColorScheme)
    }
}

 