//
//  ContentView.swift
//  Kipped
//
//  Created by Ben Robinson on 28/06/2025.
//

import SwiftUI
import UIKit
import QuartzCore
import WebKit

struct AppFontModifier: ViewModifier {
    let font: FontOption
    
    func body(content: Content) -> some View {
        content
            .font(font.font)
    }
}

extension View {
    func appFont(_ font: FontOption) -> some View {
        self.modifier(AppFontModifier(font: font))
    }
}

enum AppTheme: String, CaseIterable {
    case light = "light"
    case system = "system"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

struct ContentView: View {
    @StateObject private var todoViewModel = TodoViewModel()
    @State private var showingAddTodo = false
    @State private var selectedTodo: Todo? = nil
    @State private var showingSettings = false
    @State private var showingAccentSheet = false
    @State private var showingAppIconSheet = false
    @State private var showingThemeSheet = false
    @State private var showingFontSheet = false
    @AppStorage("selectedAppIcon") private var selectedAppIcon: AppIconOption = .default
    @Binding var appTheme: AppTheme
    @Binding var accentColor: Color
    @Binding var notificationsEnabled: Bool
    @Binding var hapticsEnabled: Bool
    @Binding var selectedFont: FontOption
    
    private var currentColorScheme: ColorScheme? {
        switch appTheme {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { showingSettings = true }) {
                            Image("AppLogoIcon")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22)
                                .foregroundColor(accentColor)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    if todoViewModel.activeTodos.isEmpty {
                        EmptyStateView(selectedFont: selectedFont)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .offset(y: -60)
                    } else {
                        ScrollViewReader { scrollProxy in
                            ScrollView {
                                LazyVGrid(columns: [GridItem(.flexible())], spacing: 8) {
                                    ForEach(todoViewModel.activeTodos) { todo in
                                        TodoCardView(
                                            todo: todo,
                                            todoViewModel: todoViewModel,
                                            onTap: {
                                                selectedTodo = todo
                                                showingAddTodo = true
                                            },
                                            onArchive: {
                                                todoViewModel.archiveTodo(todo)
                                            },
                                            selectedFont: selectedFont
                                        )
                                        .id(todo.id)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                // Add extra space at the bottom so the last card isn't covered by the create button
                                Spacer().frame(height: 120).id("bottomSpacer")
                            }
                            .onChange(of: todoViewModel.activeTodos.count) { _ in
                                withAnimation {
                                    scrollProxy.scrollTo("bottomSpacer", anchor: .bottom)
                                }
                            }
                        }
                        .animation(.spring(), value: todoViewModel.activeTodos)
                    }
                }
                
        VStack {
                    Spacer()
                    SkeuomorphicCreateButton(
                        accentColor: accentColor,
                        action: {
                            selectedTodo = nil
                            showingAddTodo = true
                        }
                    )
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddTodo, onDismiss: { selectedTodo = nil }) {
                AddTodoView(todoViewModel: todoViewModel, todoToEdit: selectedTodo, colorScheme: .constant(.dark), accentColor: $accentColor, selectedFont: $selectedFont)
            }
            .presentationCornerRadius(60)
            .overlay(
                // Bottom sheet for settings only
                BottomSheet(
                    isPresented: showingSettings,
                    content: {
                        SettingsView(
                            appTheme: $appTheme,
                            accentColor: $accentColor,
                            notificationsEnabled: $notificationsEnabled,
                            hapticsEnabled: $hapticsEnabled,
                            colorScheme: currentColorScheme,
                            todoViewModel: todoViewModel,
                            selectedAppIcon: $selectedAppIcon,
                            selectedFont: $selectedFont,
                            onShowAccentSheet: { showingAccentSheet = true },
                            onShowAppIconSheet: { showingAppIconSheet = true },
                            onShowThemeSheet: { showingThemeSheet = true },
                            onShowFontSheet: { showingFontSheet = true }
                        )
                    },
                    onDismiss: {
                        withAnimation { showingSettings = false }
                    }
                )
            )
            .onChange(of: showingSettings) { newValue in
                if !newValue {
                    showingAccentSheet = false
                    showingAppIconSheet = false
                    showingThemeSheet = false
                    showingFontSheet = false
                }
            }
            .onAppear {
                syncAppIconOnLaunch()
            }
            }
            
            // Overlays at root level to cover everything including toolbar
            if showingAccentSheet {
                ZStack {
                    VisualEffectView(effect: UIBlurEffect(style: .light))
                        .ignoresSafeArea(.all)
                        .overlay(Color.clear)
                        .transition(.opacity)
                    AccentColorPickerOverlay(
                    isPresented: $showingAccentSheet,
                    accentColor: $accentColor,
                    colors: [
                        (Color(UIColor.systemBlue), "Blue"),
                        (Color(UIColor.systemRed), "Red"),
                        (Color(UIColor.systemGreen), "Green"),
                        (Color(UIColor.systemOrange), "Orange"),
                        (Color(UIColor.systemPurple), "Purple"),
                        (Color(UIColor.systemPink), "Pink"),
                        (Color(UIColor.systemTeal), "Teal"),
                        (Color(UIColor.systemYellow), "Yellow")
                    ],
                    onColorSelected: { color in
                        // Don't close automatically - let user tap outside to close
                    }
                )
                    .ignoresSafeArea(.all)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            if showingAppIconSheet {
                ZStack {
                    VisualEffectView(effect: UIBlurEffect(style: .light))
                        .ignoresSafeArea(.all)
                        .overlay(Color.clear)
                        .transition(.opacity)
                    AppIconSelectionOverlay(
                    isPresented: $showingAppIconSheet,
                    selectedAppIcon: $selectedAppIcon,
                    onIconSelected: { icon in
                        selectedAppIcon = icon
                        changeAppIcon(to: icon)
                    }
                )
                    .ignoresSafeArea(.all)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            if showingThemeSheet {
                ZStack {
                    VisualEffectView(effect: UIBlurEffect(style: .light))
                        .ignoresSafeArea(.all)
                        .overlay(Color.clear)
                        .transition(.opacity)
                    ThemePickerOverlay(
                    isPresented: $showingThemeSheet,
                    appTheme: $appTheme,
                    onThemeSelected: { theme in
                        appTheme = theme
                    }
                )
                    .ignoresSafeArea(.all)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            if showingFontSheet {
                ZStack {
                    VisualEffectView(effect: UIBlurEffect(style: .light))
                        .ignoresSafeArea(.all)
                        .overlay(Color.clear)
                        .transition(.opacity)
                    FontPickerOverlay(
                    isPresented: $showingFontSheet,
                    selectedFont: $selectedFont,
                    onFontSelected: { font in
                        selectedFont = font
                    }
                )
                    .ignoresSafeArea(.all)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
    
    private func syncAppIconOnLaunch() {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        
        let currentIconName = UIApplication.shared.alternateIconName
        let expectedIconName = selectedAppIcon == .default ? nil : selectedAppIcon.rawValue
        
        if currentIconName != expectedIconName {
            UIApplication.shared.setAlternateIconName(expectedIconName) { error in
                if let error = error {
                    print("Error syncing app icon on launch: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func changeAppIcon(to icon: AppIconOption) {
        print("Attempting to change app icon to: \(icon.displayName)")
        
        guard UIApplication.shared.supportsAlternateIcons else { 
            print("Alternate app icons are not supported on this device")
            // Still provide feedback even if not supported
            HapticsManager.shared.notification(.warning)
            return 
        }
        
        let iconName = icon == .default ? nil : icon.rawValue
        print("Setting alternate icon name to: \(iconName ?? "default")")
        
        UIApplication.shared.setAlternateIconName(iconName) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error changing app icon: \(error.localizedDescription)")
                    // Show error feedback
                    HapticsManager.shared.notification(.error)
                } else {
                    print("App icon successfully changed to: \(icon.displayName)")
                    // Show success feedback
                    HapticsManager.shared.notification(.success)
                    
                    // Additional haptic feedback
                    HapticsManager.shared.impact(.medium)
                }
            }
        }
    }
    
    private func deleteTodos(offsets: IndexSet) {
        for index in offsets {
            todoViewModel.deleteTodo(todoViewModel.todos[index])
        }
    }
}

struct TodoRowView: View {
    let todo: Todo
    @ObservedObject var todoViewModel: TodoViewModel
    let showCompletion: Bool
    let selectedFont: FontOption
    
    var body: some View {
        HStack {
            if showCompletion {
                Button(action: {
                    todoViewModel.toggleTodo(todo)
                }) {
                    Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(todo.isCompleted ? .green : .secondary)
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(todo.title)
                    .appFont(selectedFont)
                    .strikethrough(todo.isCompleted)
                    .foregroundColor(todo.isCompleted ? .secondary : .primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                if let reminder = todo.reminderDate {
                    Text(reminderString(from: reminder))
                        .appFont(selectedFont)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .listRowBackground(Color(UIColor.secondarySystemBackground))
    }
    
    private func reminderString(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let startOfReminder = calendar.startOfDay(for: date)
        let daysBetween = calendar.dateComponents([.day], from: startOfToday, to: startOfReminder).day ?? 0
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeString = timeFormatter.string(from: date)
        let weekdaySymbols = calendar.weekdaySymbols // Full names: Sunday, Monday, ...
        let reminderWeekday = calendar.component(.weekday, from: date)
        let thisWeek = calendar.component(.weekOfYear, from: now) == calendar.component(.weekOfYear, from: date)
        let nextWeek = calendar.component(.weekOfYear, from: now) + 1 == calendar.component(.weekOfYear, from: date)
        let dayMonthFormatter = DateFormatter()
        dayMonthFormatter.dateFormat = "EEEE d MMM" // e.g. Thursday 17 Feb

        if daysBetween == 0 {
            return "Today, \(timeString)"
        } else if daysBetween == 1 {
            return "Tomorrow, \(timeString)"
        } else if daysBetween > 1 && daysBetween < 7 && thisWeek {
            let weekday = weekdaySymbols[reminderWeekday - 1]
            return "\(weekday), \(timeString)"
        } else if nextWeek && daysBetween < 14 {
            let weekday = weekdaySymbols[reminderWeekday - 1]
            return "Next \(weekday), \(timeString)"
        } else {
            return "\(dayMonthFormatter.string(from: date)), \(timeString)"
        }
    }
}

// Extracted card view to help SwiftUI type-checking
struct TodoCardView: View {
    let todo: Todo
    @ObservedObject var todoViewModel: TodoViewModel
    let onTap: () -> Void
    let onArchive: () -> Void
    let selectedFont: FontOption

    var body: some View {
        Button(action: onTap) {
            TodoRowView(todo: todo, todoViewModel: todoViewModel, showCompletion: false, selectedFont: selectedFont)
        .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(action: {
                HapticsManager.shared.impact(.soft)
                UIPasteboard.general.string = todo.title
            }) {
                Label("Copy Text", systemImage: "doc.on.doc")
            }
            Button(role: .destructive, action: {
                HapticsManager.shared.impact(.soft)
                onArchive()
            }) {
                Label("Archive", systemImage: "archivebox")
            }
        }
    }
}

// Helper to convert SwiftUI Color to UIColor
extension UIColor {
    convenience init(_ color: Color) {
        // Try to match common system colors first
        switch color.description {
        case let desc where desc.contains("systemBlue"):
            self.init(cgColor: UIColor.systemBlue.cgColor)
        case let desc where desc.contains("systemRed"):
            self.init(cgColor: UIColor.systemRed.cgColor)
        case let desc where desc.contains("systemGreen"):
            self.init(cgColor: UIColor.systemGreen.cgColor)
        case let desc where desc.contains("systemOrange"):
            self.init(cgColor: UIColor.systemOrange.cgColor)
        case let desc where desc.contains("systemPurple"):
            self.init(cgColor: UIColor.systemPurple.cgColor)
        case let desc where desc.contains("systemPink"):
            self.init(cgColor: UIColor.systemPink.cgColor)
        case let desc where desc.contains("systemTeal"):
            self.init(cgColor: UIColor.systemTeal.cgColor)
        case let desc where desc.contains("systemYellow"):
            self.init(cgColor: UIColor.systemYellow.cgColor)
        default:
            // Fallback parsing
            let scanner = Scanner(string: color.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
            var hexNumber: UInt64 = 0
            if scanner.scanHexInt64(&hexNumber) {
                let r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                let g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                let b = CGFloat(hexNumber & 0x0000ff) / 255
                self.init(red: r, green: g, blue: b, alpha: 1)
                return
            }
            // Default to blue instead of black when parsing fails
            self.init(cgColor: UIColor.systemBlue.cgColor)
        }
    }
}

// iOS-style bottom sheet component
struct BottomSheet<Content: View>: View {
    let isPresented: Bool
    let content: () -> Content
    let onDismiss: (() -> Void)?
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false
    
    private let cornerRadius: CGFloat = 24
    private let dragIndicatorWidth: CGFloat = 40
    private let dragIndicatorHeight: CGFloat = 4
    private let dismissThreshold: CGFloat = 100
    
    var body: some View {
        ZStack {
            if isPresented {
                // Dimmed background
                Color.black
                    .opacity(0.4 * max(0.0, 1.0 - dragOffset / 300.0))
                    .ignoresSafeArea()
                    .onTapGesture {
                        onDismiss?()
                    }
                
                // The sheet itself
                GeometryReader { geometry in
                    let screenHeight = UIScreen.main.bounds.height
                    let sheetHeight = screenHeight
                    
                    VStack(spacing: 0) {
                        // Drag indicator
                        VStack(spacing: 0) {
                            Spacer().frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: dragIndicatorHeight / 2)
                                .fill(Color.secondary.opacity(0.6))
                                .frame(width: dragIndicatorWidth, height: dragIndicatorHeight)
                            
                            Spacer().frame(height: 16)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemBackground))
                        .clipShape(
                            RoundedCorner(radius: cornerRadius, corners: [.topLeft, .topRight])
                        )
                        
                        // Content area
                        ScrollView {
                            VStack(spacing: 0) {
                                // Settings title
                                Text("Settings")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .padding(.top, 10)
                                    .padding(.bottom, 16)
                                
                                content()
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 100)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(UIColor.systemBackground))
                    }
                    .frame(height: sheetHeight, alignment: .top)
                    .background(Color(UIColor.systemBackground))
                    .clipShape(
                        RoundedCorner(radius: cornerRadius, corners: [.topLeft, .topRight])
                    )
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: -5)
                    .offset(x: 0, y: max(0, dragOffset))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newOffset = max(0, value.translation.height)
                                dragOffset = newOffset
                                isDragging = true
                            }
                            .onEnded { value in
                                isDragging = false
                                
                                if dragOffset > dismissThreshold {
                                    onDismiss?()
                                } else {
                                    // Snap back to original position
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        dragOffset = 0
                                    }
                                }
                            }
                    )
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .ignoresSafeArea(edges: .bottom)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPresented)
        .onChange(of: isPresented) { presented in
            if presented {
                dragOffset = 0
            }
        }
    }
}

// Helper for rounding only specific corners
struct RoundedCorner: Shape {
    var radius: CGFloat = 16.0
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct SkeuomorphicColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    private var buttonSize: CGFloat { 64 }
    
    private var brightColor: Color {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return Color(
            red: min(1.0, r + 0.3),
            green: min(1.0, g + 0.3),
            blue: min(1.0, b + 0.3)
        )
    }
    
    private var darkColor: Color {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return Color(
            red: max(0.0, r - 0.4),
            green: max(0.0, g - 0.4),
            blue: max(0.0, b - 0.4)
        )
    }
    
    private var mainGradient: RadialGradient {
        RadialGradient(
            gradient: Gradient(stops: [
                .init(color: brightColor.opacity(0.95), location: 0.0),
                .init(color: color, location: 0.4),
                .init(color: darkColor.opacity(0.8), location: 0.8),
                .init(color: darkColor.opacity(0.9), location: 1.0)
            ]),
            center: UnitPoint(x: 0.3, y: 0.3),
            startRadius: 0,
            endRadius: buttonSize * 0.8
        )
    }
    
    var body: some View {
        Button(action: {
            HapticsManager.shared.impact(.soft)
            action()
        }) {
            ZStack {
                // Shadow
                Circle()
                    .fill(Color.black.opacity(0.1))
                    .frame(width: buttonSize + 4, height: buttonSize + 4)
                    .blur(radius: 2)
                    .offset(x: 0, y: 2)
                
                // Main button
                Circle()
                    .fill(mainGradient)
                    .frame(width: buttonSize, height: buttonSize)
                    .overlay(
                        Circle()
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
                                lineWidth: 3
                            )
                    )
                    .overlay(
                        // Inner rim
                        Circle()
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
                                lineWidth: 1.5
                            )
                            .frame(width: buttonSize - 4, height: buttonSize - 4)
                    )
                    .overlay(
                        // Gloss overlay
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color.white.opacity(0.6), location: 0.0),
                                        .init(color: Color.white.opacity(0.2), location: 0.3),
                                        .init(color: Color.clear, location: 0.7),
                                        .init(color: Color.clear, location: 1.0)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: buttonSize * 0.7, height: buttonSize * 0.7)
                            .offset(x: -buttonSize * 0.1, y: -buttonSize * 0.1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
                    .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                    .overlay(
                        // Selection indicator
                        Circle()
                            .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                            .frame(width: buttonSize + 6, height: buttonSize + 6)
                            .shadow(color: .black.opacity(isSelected ? 0.3 : 0), radius: 2)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                    )
                    .scaleEffect(isPressed ? 0.92 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
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

struct SkeuomorphicThemeButton: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    
    private let buttonSize: CGFloat = 68
    
    private var themeColor: Color {
        switch theme {
        case .light:
            return Color(red: 0.96, green: 0.96, blue: 0.98) // Light gray-blue
        case .dark:
            return Color.black // Pure black
        case .system:
            return Color(red: 0.5, green: 0.5, blue: 0.55) // Medium gray
        }
    }
    
    private var brightColor: Color {
        let base = themeColor
        let uiColor = UIColor(base)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return Color(
            red: min(1.0, r + 0.3),
            green: min(1.0, g + 0.3),
            blue: min(1.0, b + 0.3)
        )
    }
    
    private var darkColor: Color {
        let base = themeColor
        let uiColor = UIColor(base)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return Color(
            red: max(0.0, r - 0.4),
            green: max(0.0, g - 0.4),
            blue: max(0.0, b - 0.4)
        )
    }
    
    private var mainGradient: RadialGradient {
        RadialGradient(
            gradient: Gradient(stops: [
                .init(color: brightColor.opacity(0.95), location: 0.0),
                .init(color: themeColor, location: 0.4),
                .init(color: darkColor.opacity(0.8), location: 0.8),
                .init(color: darkColor.opacity(0.9), location: 1.0)
            ]),
            center: UnitPoint(x: 0.3, y: 0.3),
            startRadius: 0,
            endRadius: buttonSize * 0.8
        )
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(mainGradient)
                    .frame(width: buttonSize, height: buttonSize)
                    .overlay(
                        Circle()
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
                                lineWidth: 3
                            )
                    )
                    .overlay(
                        Circle()
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
                                lineWidth: 1.5
                            )
                            .frame(width: buttonSize - 4, height: buttonSize - 4)
                    )
                    .overlay(
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color.white.opacity(0.6), location: 0.0),
                                        .init(color: Color.white.opacity(0.2), location: 0.3),
                                        .init(color: Color.clear, location: 0.7),
                                        .init(color: Color.clear, location: 1.0)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: buttonSize * 0.7, height: buttonSize * 0.7)
                            .offset(x: -buttonSize * 0.1, y: -buttonSize * 0.1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
                    .shadow(color: themeColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    .overlay(
                        // Selection indicator
                        Circle()
                            .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                            .frame(width: buttonSize + 6, height: buttonSize + 6)
                            .shadow(color: .black.opacity(isSelected ? 0.3 : 0), radius: 2)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                    )
                    .scaleEffect(isPressed ? 0.92 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
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

struct AccentColorPickerOverlay: View {
    @Binding var isPresented: Bool
    @Binding var accentColor: Color
    let colors: [(Color, String)]
    let onColorSelected: (Color) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    func isColorSelected(_ color1: Color, _ color2: Color) -> Bool {
        // Convert to UIColor for comparison
        let uiColor1 = UIColor(color1)
        let uiColor2 = UIColor(color2)
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        // Use Euclidean distance for more accurate color matching
        let distance = sqrt(pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2))
        return distance < 0.1
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 20) {
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(colors, id: \.1) { color, name in
                            SkeuomorphicColorButton(
                                color: color,
                                isSelected: isColorSelected(accentColor, color),
                                action: {
                                    accentColor = color
                                    onColorSelected(color)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .background(Color.clear)
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            }
        }
    }
}

struct AppIconSelectionOverlay: View {
    @Binding var isPresented: Bool
    @Binding var selectedAppIcon: AppIconOption
    let onIconSelected: (AppIconOption) -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var pressedOption: AppIconOption? = nil
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 20) {
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                        ForEach(AppIconOption.allCases, id: \.self) { option in
                            Button(action: {
                                HapticsManager.shared.impact(.soft)
                                selectedAppIcon = option
                                onIconSelected(option)
                            }) {
                                ZStack {
                                    Image(option.imagePreviewName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 88, height: 88)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
                                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                                        .overlay(
                                            // Selection indicator
                                            RoundedRectangle(cornerRadius: 23)
                                                .stroke(Color.white, lineWidth: selectedAppIcon == option ? 3 : 0)
                                                .frame(width: 94, height: 94)
                                                .shadow(color: .black.opacity(selectedAppIcon == option ? 0.3 : 0), radius: 2)
                                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedAppIcon == option)
                                        )
                                        .scaleEffect(pressedOption == option ? 0.92 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pressedOption == option)
                                }
                                .frame(width: 98, height: 98)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                                withAnimation(.easeInOut(duration: 0.12)) {
                                    pressedOption = pressing ? option : nil
                                }
                            }, perform: {})
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .background(Color.clear)
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            }
        }
    }
}

struct ThemePickerOverlay: View {
    @Binding var isPresented: Bool
    @Binding var appTheme: AppTheme
    let onThemeSelected: (AppTheme) -> Void
    
    func themeColor(for theme: AppTheme) -> Color {
        switch theme {
        case .system:
            return Color.gray
        case .light:
            return Color.white
        case .dark:
            return Color.black
        }
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 20) {
                    
                    HStack(spacing: 20) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            SkeuomorphicThemeButton(
                                theme: theme,
                                isSelected: appTheme == theme,
                                action: {
                                    HapticsManager.shared.impact(.soft)
                                    appTheme = theme
                                    onThemeSelected(theme)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
                .background(Color.clear)
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            }
        }
    }
}

struct FontPickerOverlay: View {
    @Binding var isPresented: Bool
    @Binding var selectedFont: FontOption
    let onFontSelected: (FontOption) -> Void
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 20) {
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                        ForEach(FontOption.allCases, id: \.self) { font in
                            SkeuomorphicFontButton(
                                font: font,
                                isSelected: selectedFont == font,
                                action: {
                                    HapticsManager.shared.impact(.soft)
                                    selectedFont = font
                                    onFontSelected(font)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .background(Color.clear)
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            }
        }
    }
}

struct EmptyStateView: View {
    @State private var gifURL: URL?
    let selectedFont: FontOption
    
    var body: some View {
        VStack(spacing: 20) {
            // Video/GIF illustration placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.clear)
                    .frame(width: 120, height: 120)
                
                // Load GIF from Data Set in Assets
                if let url = gifURL {
                    WebView(url: url)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    // Fallback to system icon
                    Image(systemName: "checklist")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                }
            }
            
            Text("Add a note")
                .appFont(selectedFont)
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .onAppear {
            loadGIF()
        }
    }
    
    private func loadGIF() {
        if let dataAsset = NSDataAsset(name: "LogoGif") {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("LogoGif.gif")
            do {
                try dataAsset.data.write(to: tempURL)
                gifURL = tempURL
            } catch {
                print("Failed to write GIF to temp directory: \(error)")
            }
        }
    }
}

// Simple WebView for displaying GIF files
struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct SkeuomorphicFontButton: View {
    let font: FontOption
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    @Environment(\.colorScheme) var colorScheme
    
    private let buttonHeight: CGFloat = 56
    private let buttonWidth: CGFloat = 90
    
    private var buttonGradient: RadialGradient {
        if colorScheme == .dark {
            return RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.25, green: 0.25, blue: 0.27), location: 0.0),
                    .init(color: Color(red: 0.20, green: 0.20, blue: 0.22), location: 0.4),
                    .init(color: Color(red: 0.15, green: 0.15, blue: 0.17), location: 0.8),
                    .init(color: Color(red: 0.10, green: 0.10, blue: 0.12), location: 1.0)
                ]),
                center: UnitPoint(x: 0.3, y: 0.3),
                startRadius: 0,
                endRadius: buttonWidth * 0.6
            )
        } else {
            return RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.96, green: 0.96, blue: 0.98), location: 0.0),
                    .init(color: Color(red: 0.92, green: 0.92, blue: 0.94), location: 0.4),
                    .init(color: Color(red: 0.88, green: 0.88, blue: 0.90), location: 0.8),
                    .init(color: Color(red: 0.84, green: 0.84, blue: 0.86), location: 1.0)
                ]),
                center: UnitPoint(x: 0.3, y: 0.3),
                startRadius: 0,
                endRadius: buttonWidth * 0.6
            )
        }
    }
    
    var body: some View {
        Button(action: {
            HapticsManager.shared.impact(.soft)
            action()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(buttonGradient)
                    .frame(width: buttonWidth, height: buttonHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
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
                                lineWidth: 3
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
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
                                lineWidth: 1.5
                            )
                            .frame(width: buttonWidth - 4, height: buttonHeight - 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color.white.opacity(0.6), location: 0.0),
                                        .init(color: Color.white.opacity(0.2), location: 0.3),
                                        .init(color: Color.clear, location: 0.7),
                                        .init(color: Color.clear, location: 1.0)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: buttonWidth * 0.7, height: buttonHeight * 0.7)
                            .offset(x: -buttonWidth * 0.1, y: -buttonHeight * 0.1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
                    .shadow(color: Color.gray.opacity(0.3), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 19)
                            .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                            .frame(width: buttonWidth + 6, height: buttonHeight + 6)
                            .shadow(color: .black.opacity(isSelected ? 0.3 : 0), radius: 2)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                    )
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                
                Text(font.displayName)
                    .font(font.font)
                    .foregroundColor(.primary)
                    .fontWeight(.medium)
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

struct SkeuomorphicCreateButton: View {
    let accentColor: Color
    let action: () -> Void
    @State private var isPressed = false
    
    private var buttonSize: CGFloat { 64 }
    
    private var brightColor: Color {
        let uiColor = UIColor(accentColor)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return Color(
            red: min(1.0, r + 0.3),
            green: min(1.0, g + 0.3),
            blue: min(1.0, b + 0.3)
        )
    }
    
    private var darkColor: Color {
        let uiColor = UIColor(accentColor)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return Color(
            red: max(0.0, r - 0.4),
            green: max(0.0, g - 0.4),
            blue: max(0.0, b - 0.4)
        )
    }
    
    private var mainGradient: RadialGradient {
        RadialGradient(
            gradient: Gradient(stops: [
                .init(color: brightColor.opacity(0.95), location: 0.0),
                .init(color: accentColor, location: 0.4),
                .init(color: darkColor.opacity(0.8), location: 0.8),
                .init(color: darkColor.opacity(0.9), location: 1.0)
            ]),
            center: UnitPoint(x: 0.3, y: 0.3),
            startRadius: 0,
            endRadius: buttonSize * 0.8
        )
    }
    
    var body: some View {
        Button(action: {
            HapticsManager.shared.impact(.soft)
            action()
        }) {
            ZStack {
                // Shadow
                Circle()
                    .fill(Color.black.opacity(0.1))
                    .frame(width: buttonSize + 4, height: buttonSize + 4)
                    .blur(radius: 2)
                    .offset(x: 0, y: 2)
                
                // Main button
                Circle()
                    .fill(mainGradient)
                    .frame(width: buttonSize, height: buttonSize)
                    .overlay(
                        Circle()
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
                                lineWidth: 3
                            )
                    )
                    .overlay(
                        // Inner rim
                        Circle()
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
                                lineWidth: 1.5
                            )
                            .frame(width: buttonSize - 4, height: buttonSize - 4)
                    )
                    .overlay(
                        // Gloss overlay
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color.white.opacity(0.6), location: 0.0),
                                        .init(color: Color.white.opacity(0.2), location: 0.3),
                                        .init(color: Color.clear, location: 0.7),
                                        .init(color: Color.clear, location: 1.0)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: buttonSize * 0.7, height: buttonSize * 0.7)
                            .offset(x: -buttonSize * 0.1, y: -buttonSize * 0.1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
                    .shadow(color: accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    .scaleEffect(isPressed ? 0.92 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                
                // Plus icon
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .scaleEffect(isPressed ? 0.85 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
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

#Preview {
    ContentView(appTheme: .constant(.dark), accentColor: .constant(.accentColor), notificationsEnabled: .constant(true), hapticsEnabled: .constant(true), selectedFont: .constant(.system))
}