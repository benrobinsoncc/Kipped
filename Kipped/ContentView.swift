//
//  ContentView.swift
//  Kipped
//
//  Created by Ben Robinson on 28/06/2025.
//

import SwiftUI

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
                        .frame(height: geometry.size.height - 120) // Reserve space for bottom UI only
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    }
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Image("AppLogoIcon")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22)
                                .foregroundColor(accentColor)
                                .materialStyle(accentColor: accentColor)
                                .highPriorityGesture(
                                    TapGesture()
                                        .onEnded {
                                            showingSettings = true
                                        }
                                )
                        }
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

