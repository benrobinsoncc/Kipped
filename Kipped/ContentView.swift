//
//  ContentView.swift
//  Kipped
//
//  Created by Ben Robinson on 28/06/2025.
//

import SwiftUI

struct SmudgeParticle: Identifiable {
    let id = UUID()
    let position: CGPoint
    let creationTime: Date
    var opacity: Double = 1.0
    var scale: Double = 1.0
    
    init(position: CGPoint) {
        self.position = position
        self.creationTime = Date()
    }
}

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
    @StateObject private var viewModel = PositiveNoteViewModel()
    @State private var viewMode: ViewMode = .year
    @State private var showingAddNote = false
    @State private var selectedNote: PositiveNote?
    @State private var selectedDate: Date?
    @State private var showingSettings = false
    @State private var currentMonth = Date()
    @State private var smudgeParticles: [SmudgeParticle] = []
    @State private var isDragging = false
    @State private var lastDragPosition: CGPoint?
    
    @AppStorage("selectedAppIcon") private var selectedAppIcon: AppIconOption = .default
    @Binding var appTheme: AppTheme
    @Binding var accentColor: Color
    @Binding var notificationsEnabled: Bool
    @Binding var hapticsEnabled: Bool
    @Binding var selectedFont: FontOption
    @Binding var tintedBackgrounds: Bool
    
    private var currentColorScheme: ColorScheme? {
        switch appTheme {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    private var tintedBackground: Color {
        Color.tintedBackground(accentColor: accentColor, isEnabled: tintedBackgrounds, colorScheme: currentColorScheme)
    }
    
    // MARK: - Smudge Effect Methods
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        let currentPosition = value.location
        
        if !isDragging {
            isDragging = true
            createSmudgeParticle(at: currentPosition)
        } else {
            if let lastPos = lastDragPosition {
                let distance = sqrt(pow(currentPosition.x - lastPos.x, 2) + pow(currentPosition.y - lastPos.y, 2))
                if distance > 3.0 {
                    createSmudgeParticle(at: currentPosition)
                }
            }
        }
        
        lastDragPosition = currentPosition
    }
    
    private func handleDragEnded() {
        isDragging = false
        lastDragPosition = nil
    }
    
    private func createSmudgeParticle(at position: CGPoint) {
        let newParticle = SmudgeParticle(position: position)
        smudgeParticles.append(newParticle)
        
        if smudgeParticles.count > 35 {
            smudgeParticles.removeFirst()
        }
        
        let particleIndex = smudgeParticles.count - 1
        let fadeStartDelay = 0.05 + (Double(particleIndex) * 0.008)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeStartDelay) {
            withAnimation(.easeOut(duration: 0.25)) {
                if let index = smudgeParticles.firstIndex(where: { $0.id == newParticle.id }) {
                    smudgeParticles[index].opacity = 0.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                smudgeParticles.removeAll { $0.id == newParticle.id }
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            tintedBackground
                .ignoresSafeArea()
            
            // Smudge particles
            ForEach(smudgeParticles) { particle in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                accentColor.opacity(currentColorScheme == .dark ? 0.18 : 0.12),
                                accentColor.opacity(currentColorScheme == .dark ? 0.14 : 0.09),
                                accentColor.opacity(currentColorScheme == .dark ? 0.10 : 0.06),
                                accentColor.opacity(currentColorScheme == .dark ? 0.06 : 0.04),
                                accentColor.opacity(currentColorScheme == .dark ? 0.04 : 0.025),
                                accentColor.opacity(currentColorScheme == .dark ? 0.025 : 0.015),
                                accentColor.opacity(currentColorScheme == .dark ? 0.015 : 0.008),
                                accentColor.opacity(currentColorScheme == .dark ? 0.008 : 0.004),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 90
                        )
                    )
                    .frame(width: 160, height: 160)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .blendMode(currentColorScheme == .dark ? .screen : .multiply)
                    .zIndex(999)
            }
            
            GeometryReader { geometry in
                NavigationStack {
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Spacer()
                            
                            // Settings button (centered)
                            Button(action: { showingSettings = true }) {
                                Image("AppLogoIcon")
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 22, height: 22)
                                    .foregroundColor(accentColor)
                                    .materialStyle(accentColor: accentColor)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                        
                        // Main content (full height available)
                        Group {
                            switch viewMode {
                            case .year:
                                YearView(
                                    viewModel: viewModel,
                                    selectedDate: $selectedDate,
                                    accentColor: accentColor,
                                    selectedFont: selectedFont,
                                    tintedBackgrounds: tintedBackgrounds,
                                    colorScheme: currentColorScheme
                                )
                            case .month:
                                MonthView(
                                    viewModel: viewModel,
                                    selectedDate: $selectedDate,
                                    currentMonth: $currentMonth,
                                    accentColor: accentColor,
                                    selectedFont: selectedFont,
                                    tintedBackgrounds: tintedBackgrounds,
                                    colorScheme: currentColorScheme
                                )
                            case .week:
                                PositivityListView(
                                    viewModel: viewModel,
                                    selectedNote: $selectedNote,
                                    showingAddNote: $showingAddNote,
                                    accentColor: accentColor,
                                    selectedFont: selectedFont,
                                    tintedBackgrounds: tintedBackgrounds,
                                    colorScheme: currentColorScheme
                                )
                            }
                        }
                        .frame(height: geometry.size.height - 160) // Reserve space for header + bottom UI
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    }
                }
            }
                
            // Bottom UI elements
            VStack {
                Spacer()
                
                VStack(spacing: 16) {
                    // View switcher (bottom left)
                    HStack {
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                let currentIndex = ViewMode.allCases.firstIndex(of: viewMode) ?? 0
                                let nextIndex = (currentIndex + 1) % ViewMode.allCases.count
                                viewMode = ViewMode.allCases[nextIndex]
                            }
                            HapticsManager.shared.impact(.soft)
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(accentColor)
                                
                                Text(viewMode.displayName)
                                    .appFont(selectedFont)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(accentColor)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.tintedSecondaryBackground(accentColor: accentColor, isEnabled: tintedBackgrounds, colorScheme: currentColorScheme))
                            .cornerRadius(20)
                        }
                        
                        Spacer()
                    }
                            
                    // Create button (centered)
                    HStack {
                        Spacer()
                        SkeuomorphicCreateButton(
                            accentColor: accentColor,
                            action: {
                                selectedDate = Date()
                                showingAddNote = true
                            }
                        )
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    handleDragChanged(value)
                }
                .onEnded { _ in
                    handleDragEnded()
                }
        )
        .sheet(isPresented: $showingAddNote) {
            AddPositiveNoteView(
                viewModel: viewModel,
                noteToEdit: selectedNote,
                dateToEdit: selectedDate,
                accentColor: $accentColor,
                selectedFont: $selectedFont
            )
            .onDisappear {
                selectedNote = nil
                selectedDate = nil
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(
                appTheme: $appTheme,
                accentColor: $accentColor,
                notificationsEnabled: $notificationsEnabled,
                hapticsEnabled: $hapticsEnabled,
                colorScheme: currentColorScheme,
                todoViewModel: TodoViewModel(), // Temporarily keep for compatibility
                selectedAppIcon: $selectedAppIcon,
                selectedFont: $selectedFont,
                tintedBackgrounds: $tintedBackgrounds
            )
        }
        .onChange(of: selectedDate) { _, date in
            if date != nil {
                showingAddNote = true
            }
        }
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
                
                // Main button with material texture
                Circle()
                    .fill(mainGradient)
                    .frame(width: buttonSize, height: buttonSize)
                    .materialStyle(accentColor: accentColor)
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
                
                // Plus icon
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .scaleEffect(isPressed ? 0.85 : 1.0)
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
