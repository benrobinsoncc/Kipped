//
//  ContentView.swift
//  Kipped
//
//  Created by Ben Robinson on 28/06/2025.
//

import SwiftUI

struct DragLocationKey: PreferenceKey {
    static var defaultValue: CGPoint?
    
    static func reduce(value: inout CGPoint?, nextValue: () -> CGPoint?) {
        value = nextValue() ?? value
    }
}

// Pass drag handler to child views
struct DragHandlerKey: EnvironmentKey {
    static let defaultValue: ((CGPoint) -> Void)? = nil
}

struct DragEndHandlerKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension EnvironmentValues {
    var dragHandler: ((CGPoint) -> Void)? {
        get { self[DragHandlerKey.self] }
        set { self[DragHandlerKey.self] = newValue }
    }
    
    var dragEndHandler: (() -> Void)? {
        get { self[DragEndHandlerKey.self] }
        set { self[DragEndHandlerKey.self] = newValue }
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
    @State private var notificationObserver: NSObjectProtocol?
    @Namespace private var animationNamespace
    @State private var zoomScale: CGFloat = 1.0
    @State private var zoomOffset: CGSize = .zero
    @State private var navigatedViaZoom: Bool = false
    @State private var pinchUnitPoint: UnitPoint = .center
    @State private var settingsPressed = false
    @State private var viewSwitcherPressed = false
    @State private var showingMemories = false
    
    @AppStorage("selectedAppIcon") private var selectedAppIcon: AppIconOption = .default
    @Binding var appTheme: AppTheme
    @Binding var accentColor: Color
    @Binding var notificationsEnabled: Bool
    @Binding var hapticsEnabled: Bool
    @Binding var selectedFont: FontOption
    @Binding var tintedBackgrounds: Bool
    @Binding var showAddEntry: Bool
    
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
                        // Main content
                        Group {
                            switch viewMode {
                            case .year:
                                YearView(
                                    viewModel: viewModel,
                                    selectedDate: $selectedDate,
                                    viewMode: $viewMode,
                                    currentMonth: $currentMonth,
                                    zoomScale: $zoomScale,
                                    zoomOffset: $zoomOffset,
                                    navigatedViaZoom: $navigatedViaZoom,
                                    accentColor: accentColor,
                                    selectedFont: selectedFont,
                                    tintedBackgrounds: tintedBackgrounds,
                                    colorScheme: currentColorScheme,
                                    animationNamespace: animationNamespace,
                                    containerSize: geometry.size,
                                    pinchUnitPoint: pinchUnitPoint
                                )
                                .environment(\.dragHandler, { location in
                                    let currentPosition = location
                                    
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
                                })
                                .environment(\.dragEndHandler, {
                                    isDragging = false
                                    lastDragPosition = nil
                                })
                                .frame(height: geometry.size.height - 120) // Match MonthView constraint
                                .scaleEffect(zoomScale, anchor: .center)
                                .offset(zoomOffset)
                                .gesture(
                                    MagnificationGesture()
                                        .simultaneously(with: DragGesture(minimumDistance: 0))
                                        .onChanged { value in
                                            if let scale = value.first {
                                                zoomScale = scale
                                            }
                                            
                                            if let location = value.second?.location {
                                                // Convert to unit point (0-1 range)
                                                let width = geometry.size.width
                                                let height = geometry.size.height - 120
                                                pinchUnitPoint = UnitPoint(
                                                    x: location.x / width,
                                                    y: location.y / height
                                                )
                                            }
                                        }
                                        .onEnded { value in
                                            if let scale = value.first, scale > 1.5 {
                                                // Let YearView handle month detection since it knows the layout
                                                navigatedViaZoom = true
                                            }
                                            
                                            // Reset
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                zoomScale = 1.0
                                                zoomOffset = .zero
                                            }
                                        }
                                )
                            case .month:
                                MonthView(
                                    viewModel: viewModel,
                                    selectedDate: $selectedDate,
                                    selectedNote: $selectedNote,
                                    currentMonth: $currentMonth,
                                    accentColor: accentColor,
                                    selectedFont: selectedFont,
                                    tintedBackgrounds: tintedBackgrounds,
                                    colorScheme: currentColorScheme,
                                    animationNamespace: animationNamespace,
                                    skipAnimation: navigatedViaZoom
                                )
                                .environment(\.dragHandler, { location in
                                    let currentPosition = location
                                    
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
                                })
                                .environment(\.dragEndHandler, {
                                    isDragging = false
                                    lastDragPosition = nil
                                })
                                .frame(height: geometry.size.height - 120) // Constrain year/month views
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
                                .environment(\.dragHandler, { location in
                                    let currentPosition = location
                                    
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
                                })
                                .environment(\.dragEndHandler, {
                                    isDragging = false
                                    lastDragPosition = nil
                                })
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .mask(
                                    // Fade mask for bottom 100pts
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: Color.black, location: 0.0),
                                            .init(color: Color.black, location: 0.7),
                                            .init(color: Color.black.opacity(0.3), location: 0.9),
                                            .init(color: Color.clear, location: 1.0)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            }
                        }
                        .padding(.top, -80) // Reduce gap between navigation and content
                        .zIndex(viewMode == .year ? 1 : 0) // Ensure year view is on top during transition
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
                                .scaleEffect(settingsPressed ? 0.92 : 1.0)
                                .onTapGesture {
                                    showingSettings = true
                                }
                                .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                                    withAnimation(.easeInOut(duration: 0.12)) {
                                        settingsPressed = pressing
                                    }
                                }, perform: {})
                        }
                    }
                }
            }
                
            // Bottom UI elements
            VStack {
                Spacer()
                
                ZStack {
                    // Create button (always centered)
                    SkeuomorphicCreateButton(
                        accentColor: accentColor,
                        action: {
                            selectedNote = nil  // Clear any selected note
                            selectedDate = Date()
                            showingAddNote = true
                        }
                    )
                    
                    // View switcher (left aligned) and Memories button (right aligned)
                    HStack {
                        Button(action: {
                            // Reset zoom when changing views
                            navigatedViaZoom = false
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                zoomScale = 1.0
                                zoomOffset = .zero
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
                            .scaleEffect(viewSwitcherPressed ? 0.92 : 1.0)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                            withAnimation(.easeInOut(duration: 0.12)) {
                                viewSwitcherPressed = pressing
                            }
                        }, perform: {})
                        
                        Spacer()
                        
                        // Memories button (right aligned)
                        Button(action: {
                            showingMemories = true
                            HapticsManager.shared.impact(.soft)
                        }) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(accentColor)
                                .frame(width: 44, height: 44)
                                .background(Color.tintedSecondaryBackground(accentColor: accentColor, isEnabled: tintedBackgrounds, colorScheme: currentColorScheme))
                                .cornerRadius(22)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
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
                tintedBackgrounds: $tintedBackgrounds,
                viewModel: viewModel
            )
        }
        .sheet(isPresented: $showingMemories) {
            MemoriesView(
                viewModel: viewModel,
                accentColor: $accentColor,
                selectedFont: $selectedFont,
                tintedBackgrounds: $tintedBackgrounds
            )
        }
        .onChange(of: selectedDate) { oldValue, newValue in
            if newValue != nil {
                showingAddNote = true
            }
        }
        .onChange(of: showAddEntry) { _, newValue in
            if newValue {
                selectedDate = Date()
                showingAddNote = true
                showAddEntry = false
            }
        }
        .onAppear {
            // Listen for notification taps
            notificationObserver = NotificationCenter.default.addObserver(
                forName: NotificationManager.notificationTappedNotification,
                object: nil,
                queue: .main
            ) { _ in
                // Set the selected date to today (start of day) and show the add note modal
                selectedDate = Calendar.current.startOfDay(for: Date())
                showingAddNote = true
            }
        }
        .onDisappear {
            // Remove the observer when view disappears
            if let observer = notificationObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }
}

