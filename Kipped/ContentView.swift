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
    @AppStorage("selectedAppIcon") private var selectedAppIcon: AppIconOption = .default
    @Binding var appTheme: AppTheme
    @Binding var accentColor: Color
    @Binding var notificationsEnabled: Bool
    
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
                            Image(systemName: "face.smiling")
                                .font(.title)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    if todoViewModel.activeTodos.isEmpty {
                        EmptyStateView()
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
                                            }
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
                    Button(action: {
                        selectedTodo = nil
                        showingAddTodo = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.accentColor)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddTodo, onDismiss: { selectedTodo = nil }) {
                AddTodoView(todoViewModel: todoViewModel, todoToEdit: selectedTodo, colorScheme: .constant(.dark), accentColor: $accentColor)
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
                            colorScheme: currentColorScheme,
                            todoViewModel: todoViewModel,
                            selectedAppIcon: $selectedAppIcon,
                            onShowAccentSheet: { showingAccentSheet = true },
                            onShowAppIconSheet: { showingAppIconSheet = true },
                            onShowThemeSheet: { showingThemeSheet = true }
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
                    onColorSelected: { _ in }
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
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            return 
        }
        
        let iconName = icon == .default ? nil : icon.rawValue
        print("Setting alternate icon name to: \(iconName ?? "default")")
        
        UIApplication.shared.setAlternateIconName(iconName) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error changing app icon: \(error.localizedDescription)")
                    // Show error feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                } else {
                    print("App icon successfully changed to: \(icon.displayName)")
                    // Show success feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    // Additional haptic feedback
                    let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
                    impactGenerator.impactOccurred()
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
                    .strikethrough(todo.isCompleted)
                    .foregroundColor(todo.isCompleted ? .secondary : .primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                if let reminder = todo.reminderDate {
                    Text(reminderString(from: reminder))
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

    var body: some View {
        Button(action: onTap) {
            TodoRowView(todo: todo, todoViewModel: todoViewModel, showCompletion: false)
        .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(action: {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                UIPasteboard.general.string = todo.title
            }) {
                Label("Copy Text", systemImage: "doc.on.doc")
            }
            Button(role: .destructive, action: {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
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
                                    .font(.title2)
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
        
        // Compare with small tolerance for floating point comparison
        let tolerance: CGFloat = 0.01
        return abs(r1 - r2) < tolerance && 
               abs(g1 - g2) < tolerance && 
               abs(b1 - b2) < tolerance
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
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 6) {
                        ForEach(colors, id: \.1) { color, name in
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                accentColor = color
                                onColorSelected(color)
                            }) {
                                ZStack {
                                    Circle()
                                        .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: isColorSelected(accentColor, color) ? 2 : 0)
                                        .frame(width: 74, height: 74)
                                    Circle()
                                        .fill(color)
                                        .frame(width: 64, height: 64)
                                }
                                .frame(width: 74, height: 74)
                            }
                            .buttonStyle(PlainButtonStyle())
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
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                        ForEach(AppIconOption.allCases, id: \.self) { option in
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                selectedAppIcon = option
                                onIconSelected(option)
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: selectedAppIcon == option ? 2 : 0)
                                        .frame(width: 98, height: 98)
                                    Image(option.imagePreviewName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 88, height: 88)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                }
                                .frame(width: 98, height: 98)
                            }
                            .buttonStyle(PlainButtonStyle())
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
                    
                    HStack(spacing: 12) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                appTheme = theme
                                onThemeSelected(theme)
                            }) {
                                ZStack {
                                    Circle()
                                        .stroke(appTheme == theme && theme == .dark ? Color.white : Color.black, lineWidth: appTheme == theme ? 2 : 0)
                                        .frame(width: 74, height: 74)
                                    if theme == .system {
                                        ZStack {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 64, height: 64)
                                            VStack(spacing: 0) {
                                                Rectangle()
                                                    .fill(Color.white)
                                                    .frame(width: 64, height: 32)
                                                Rectangle()
                                                    .fill(Color.black)
                                                    .frame(width: 64, height: 32)
                                            }
                                            .clipShape(Circle())
                                            .frame(width: 64, height: 64)
                                            Circle()
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                                .frame(width: 64, height: 64)
                                        }
                                    } else {
                                        ZStack {
                                            Circle()
                                                .fill(themeColor(for: theme))
                                                .frame(width: 64, height: 64)
                                            if theme == .light {
                                                Circle()
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                                    .frame(width: 64, height: 64)
                                            }
                                        }
                                    }
                                }
                                .frame(width: 74, height: 74)
                            }
                            .buttonStyle(PlainButtonStyle())
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

struct EmptyStateView: View {
    @State private var gifURL: URL?
    
    var body: some View {
        VStack(spacing: 20) {
            // Video/GIF illustration placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.1))
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
            
            Text("Add a note...")
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

#Preview {
    ContentView(appTheme: .constant(.dark), accentColor: .constant(.accentColor), notificationsEnabled: .constant(true))
}