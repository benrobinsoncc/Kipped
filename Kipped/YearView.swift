//
//  YearView.swift
//  Kipped
//
//  Created by Ben Robinson on 28/06/2025.
//

import SwiftUI

struct YearView: View {
    @ObservedObject var viewModel: PositiveNoteViewModel
    @Binding var selectedDate: Date?
    @Binding var viewMode: ViewMode
    @Binding var currentMonth: Date
    @Binding var zoomScale: CGFloat
    @Binding var zoomOffset: CGSize
    @Binding var navigatedViaZoom: Bool
    let accentColor: Color
    let selectedFont: FontOption
    let tintedBackgrounds: Bool
    let colorScheme: ColorScheme?
    let animationNamespace: Namespace.ID
    let containerSize: CGSize
    let pinchUnitPoint: UnitPoint
    
    @Environment(\.dragHandler) private var dragHandler
    @Environment(\.dragEndHandler) private var dragEndHandler
    
    @State private var noteDatesCache: Set<DateComponents> = []
    @State private var todayComponents: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    
    private let dotSize: CGFloat = 10
    private let spacing: CGFloat = 10
    private let monthGap: CGFloat = 24
    private let today = Date()
    
    // Fast lookup for note existence
    private func updateNoteCache() {
        let calendar = Calendar.current
        noteDatesCache = Set(viewModel.notes.map { note in
            calendar.dateComponents([.year, .month, .day], from: note.date)
        })
    }
    
    private func hasNote(for date: Date) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return noteDatesCache.contains(components)
    }
    
    private func isToday(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return components.year == todayComponents.year &&
               components.month == todayComponents.month &&
               components.day == todayComponents.day
    }
    
    private func getMonthIndexFromLocation(_ location: CGPoint) -> Int? {
        // Simple grid calculation - 3 columns, 4 rows
        let availableWidth = containerSize.width - 32 - 40
        let monthWidth = availableWidth / 3
        let monthHeight: CGFloat = 140
        let verticalSpacing: CGFloat = 18
        
        // Adjust for padding
        let adjustedX = location.x - 16
        let adjustedY = location.y
        
        // Calculate grid position
        let col = Int(adjustedX / (monthWidth + 20))
        let row = Int(adjustedY / (monthHeight + verticalSpacing))
        
        // Validate bounds
        if col < 0 || col > 2 || row < 0 || row > 3 {
            // Default to center month (May) if out of bounds
            return 4
        }
        
        let monthIndex = row * 3 + col
        return min(monthIndex, 11)
    }
    
    
    private var year: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    // Cache the expensive date calculations
    private let datesByMonth: [[Date]] = {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        var monthArrays: [[Date]] = Array(repeating: [], count: 12)
        
        for month in 1...12 {
            let startOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
            let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
            
            for day in 1...range.count {
                if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                    monthArrays[month - 1].append(date)
                }
            }
        }
        
        return monthArrays
    }()
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack(alignment: .leading, spacing: 18) {
                    // Row 1 - Jan, Feb, Mar
                    HStack(alignment: .top, spacing: 20) {
                        ForEach(0..<3) { col in
                            MonthDotGrid(
                                dates: datesByMonth[col],
                                monthIndex: col,
                                viewModel: viewModel,
                                selectedDate: $selectedDate,
                                accentColor: accentColor,
                                dotSize: 10,
                                spacing: 10,
                                tintedBackgrounds: tintedBackgrounds,
                                colorScheme: colorScheme,
                                animationNamespace: animationNamespace,
                                noteDatesCache: noteDatesCache,
                                todayComponents: todayComponents,
                                today: today,
                                viewMode: viewMode,
                                onTap: {
                                    let calendar = Calendar.current
                                    let year = calendar.component(.year, from: Date())
                                    if let monthDate = calendar.date(from: DateComponents(year: year, month: col + 1, day: 1)) {
                                        currentMonth = monthDate
                                        HapticsManager.shared.impact(.soft)
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            viewMode = .month
                                        }
                                    }
                                }
                            )
                        }
                    }
                    
                    // Row 2 - Apr, May, Jun
                    HStack(alignment: .top, spacing: 20) {
                        ForEach(3..<6) { monthIndex in
                            MonthDotGrid(
                                dates: datesByMonth[monthIndex],
                                monthIndex: monthIndex,
                                viewModel: viewModel,
                                selectedDate: $selectedDate,
                                accentColor: accentColor,
                                dotSize: 10,
                                spacing: 10,
                                tintedBackgrounds: tintedBackgrounds,
                                colorScheme: colorScheme,
                                animationNamespace: animationNamespace,
                                noteDatesCache: noteDatesCache,
                                todayComponents: todayComponents,
                                today: today,
                                viewMode: viewMode,
                                onTap: {
                                    let calendar = Calendar.current
                                    let year = calendar.component(.year, from: Date())
                                    if let monthDate = calendar.date(from: DateComponents(year: year, month: monthIndex + 1, day: 1)) {
                                        currentMonth = monthDate
                                        HapticsManager.shared.impact(.soft)
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            viewMode = .month
                                        }
                                    }
                                }
                            )
                        }
                    }
                    
                    // Row 3 - Jul, Aug, Sep
                    HStack(alignment: .top, spacing: 20) {
                        ForEach(6..<9) { monthIndex in
                            MonthDotGrid(
                                dates: datesByMonth[monthIndex],
                                monthIndex: monthIndex,
                                viewModel: viewModel,
                                selectedDate: $selectedDate,
                                accentColor: accentColor,
                                dotSize: 10,
                                spacing: 10,
                                tintedBackgrounds: tintedBackgrounds,
                                colorScheme: colorScheme,
                                animationNamespace: animationNamespace,
                                noteDatesCache: noteDatesCache,
                                todayComponents: todayComponents,
                                today: today,
                                viewMode: viewMode,
                                onTap: {
                                    let calendar = Calendar.current
                                    let year = calendar.component(.year, from: Date())
                                    if let monthDate = calendar.date(from: DateComponents(year: year, month: monthIndex + 1, day: 1)) {
                                        currentMonth = monthDate
                                        HapticsManager.shared.impact(.soft)
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            viewMode = .month
                                        }
                                    }
                                }
                            )
                        }
                    }
                    
                    // Row 4 - Oct, Nov, Dec
                    HStack(alignment: .top, spacing: 20) {
                        ForEach(9..<12) { monthIndex in
                            MonthDotGrid(
                                dates: datesByMonth[monthIndex],
                                monthIndex: monthIndex,
                                viewModel: viewModel,
                                selectedDate: $selectedDate,
                                accentColor: accentColor,
                                dotSize: 10,
                                spacing: 10,
                                tintedBackgrounds: tintedBackgrounds,
                                colorScheme: colorScheme,
                                animationNamespace: animationNamespace,
                                noteDatesCache: noteDatesCache,
                                todayComponents: todayComponents,
                                today: today,
                                viewMode: viewMode,
                                onTap: {
                                    let calendar = Calendar.current
                                    let year = calendar.component(.year, from: Date())
                                    if let monthDate = calendar.date(from: DateComponents(year: year, month: monthIndex + 1, day: 1)) {
                                        currentMonth = monthDate
                                        HapticsManager.shared.impact(.soft)
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            viewMode = .month
                                        }
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, -10)
                
                Spacer()
            }
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        dragHandler?(value.location)
                    }
                    .onEnded { value in
                        // Check if it's a tap (minimal movement)
                        if abs(value.translation.width) < 5 && abs(value.translation.height) < 5 {
                            // Handle tap with location
                            if let monthIndex = getMonthIndexFromLocation(value.location) {
                                let calendar = Calendar.current
                                let year = calendar.component(.year, from: Date())
                                if let monthDate = calendar.date(from: DateComponents(year: year, month: monthIndex + 1, day: 1)) {
                                    currentMonth = monthDate
                                    HapticsManager.shared.impact(.soft)
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewMode = .month
                                    }
                                }
                            }
                        }
                        dragEndHandler?()
                    }
            )
        }
        .onAppear {
            updateNoteCache()
        }
        .onChange(of: viewModel.notes) { _ in
            updateNoteCache()
        }
        .onChange(of: navigatedViaZoom) { zoomed in
            if zoomed {
                // Convert unit point to actual location
                let location = CGPoint(
                    x: pinchUnitPoint.x * containerSize.width,
                    y: pinchUnitPoint.y * containerSize.height
                )
                
                // Handle zoom navigation
                if let monthIndex = getMonthIndexFromLocation(location) {
                    let calendar = Calendar.current
                    let year = calendar.component(.year, from: Date())
                    if let monthDate = calendar.date(from: DateComponents(year: year, month: monthIndex + 1, day: 1)) {
                        currentMonth = monthDate
                        HapticsManager.shared.impact(.soft)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewMode = .month
                        }
                    }
                }
                navigatedViaZoom = false
            }
        }
    }
}

struct MonthDotGrid: View {
    let dates: [Date]
    let monthIndex: Int
    let viewModel: PositiveNoteViewModel
    @Binding var selectedDate: Date?
    let accentColor: Color
    let dotSize: CGFloat
    let spacing: CGFloat
    let tintedBackgrounds: Bool
    let colorScheme: ColorScheme?
    let animationNamespace: Namespace.ID
    let noteDatesCache: Set<DateComponents>
    let todayComponents: DateComponents
    let today: Date
    let viewMode: ViewMode
    let onTap: () -> Void
    
    private let dotsPerRow = 5 // 5 dots per row for better space utilization
    
    private let monthNames = ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"]
    
    private let maxRows = 7 // Maximum rows any month can have (31 days / 5 dots per row = 6.2, rounded up to 7)
    
    private func hasNote(for date: Date) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return noteDatesCache.contains(components)
    }
    
    private func isToday(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return components.year == todayComponents.year &&
               components.month == todayComponents.month &&
               components.day == todayComponents.day
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            // Dots container with fixed height
            VStack(spacing: spacing) {
                // Create rows of dots
                ForEach(0..<maxRows, id: \.self) { row in
                    HStack(spacing: spacing) {
                        if row < numberOfRows {
                            ForEach(0..<dotsPerRow, id: \.self) { col in
                                let index = row * dotsPerRow + col
                                if index < dates.count {
                                    let date = dates[index]
                                    
                                    DayDotView(
                                        date: date,
                                        hasNote: hasNote(for: date),
                                        isToday: isToday(date),
                                        isFuture: date > today,
                                        accentColor: accentColor,
                                        isHovered: false,
                                        dotSize: dotSize,
                                        tintedBackgrounds: tintedBackgrounds,
                                        colorScheme: colorScheme,
                                        skipAnimation: false
                                    )
                                    .allowsHitTesting(false)
                                } else {
                                    // Empty space for missing days
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: dotSize, height: dotSize)
                                }
                            }
                        } else {
                            // Empty row to maintain consistent height
                            Color.clear
                                .frame(height: dotSize)
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            
            // Month label at bottom
            Text(monthNames[monthIndex])
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(accentColor)
                .padding(.top, -21)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle()) // Make entire area tappable
        .matchedGeometryEffect(id: "month-\(monthIndex)", in: animationNamespace, isSource: viewMode == .year)
        .onTapGesture {
            onTap()
        }
    }
    
    private var numberOfRows: Int {
        Int(ceil(Double(dates.count) / Double(dotsPerRow)))
    }
}

struct DayDotView: View {
    let date: Date
    let hasNote: Bool
    let isToday: Bool
    let isFuture: Bool
    let accentColor: Color
    let isHovered: Bool
    let dotSize: CGFloat
    let tintedBackgrounds: Bool
    let colorScheme: ColorScheme?
    let skipAnimation: Bool
    
    @State private var animateIn = false
    
    private let celebratoryIcons = [
        "star.fill",
        "heart.fill",
        "sun.max.fill",
        "sparkles",
        "crown.fill",
        "party.popper.fill",
        "gift.fill",
        "balloon.fill",
        "trophy.fill",
        "medal.fill",
        "rosette",
        "hands.clap.fill",
        "flame.fill",
        "bolt.fill",
        "moon.stars.fill"
    ]
    
    private func celebratoryIcon(for date: Date) -> String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let index = (day + month) % celebratoryIcons.count
        return celebratoryIcons[index]
    }
    
    init(date: Date, hasNote: Bool, isToday: Bool, isFuture: Bool, accentColor: Color, isHovered: Bool, dotSize: CGFloat = 16, tintedBackgrounds: Bool, colorScheme: ColorScheme?, skipAnimation: Bool = false) {
        self.date = date
        self.hasNote = hasNote
        self.isToday = isToday
        self.isFuture = isFuture
        self.accentColor = accentColor
        self.isHovered = isHovered
        self.dotSize = dotSize
        self.tintedBackgrounds = tintedBackgrounds
        self.colorScheme = colorScheme
        self.skipAnimation = skipAnimation
    }
    
    private var dotColor: Color {
        if hasNote {
            return accentColor
        } else if isToday {
            return accentColor.opacity(0.3)
        } else {
            return Color.tintedSecondaryBackground(accentColor: accentColor, isEnabled: true, colorScheme: colorScheme)
        }
    }
    
    var body: some View {
        ZStack {
            if hasNote {
                // Just show the icon in accent color, no background
                Image(systemName: celebratoryIcon(for: date))
                    .font(.system(size: max(dotSize * 0.5, 8), weight: .bold))
                    .foregroundColor(accentColor)
                    .scaleEffect(animateIn ? 1 : 0)
                    .opacity(animateIn ? 1 : 0)
            } else {
                // Keep the circle for non-completed days
                Circle()
                    .fill(dotColor)
                    .frame(width: dotSize, height: dotSize)
                    .scaleEffect(animateIn ? 1 : 0.3)
                    .opacity(animateIn ? 1 : 0)
            }
            
            if isToday {
                Circle()
                    .stroke(accentColor, lineWidth: max(dotSize * 0.08, 1))
                    .frame(width: dotSize + 2, height: dotSize + 2)
            }
        }
        .onAppear {
            if skipAnimation {
                animateIn = true
            } else {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(Double.random(in: 0...0.5))) {
                    animateIn = true
                }
            }
        }
    }
}

// Helper extensions
extension Date {
    var isFuture: Bool {
        self > Date()
    }
}

// Make DateComponents hashable for our Set
extension DateComponents: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(year)
        hasher.combine(month)
        hasher.combine(day)
    }
    
    public static func == (lhs: DateComponents, rhs: DateComponents) -> Bool {
        return lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day
    }
}