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
    
    @State private var hoveredDate: Date?
    @State private var monthFrames: [Int: CGRect] = [:]
    @State private var selectedMonthForZoom: Int? = nil
    
    private let dotSize: CGFloat = 10
    private let spacing: CGFloat = 10
    private let monthGap: CGFloat = 24
    
    private func calculateZoomParameters(for monthIndex: Int) {
        // Set navigation flag and selected month
        navigatedViaZoom = true
        selectedMonthForZoom = monthIndex
        
        // Calculate the position of the month in the grid
        let row = monthIndex / 3
        let col = monthIndex % 3
        
        // Estimate the position based on grid layout
        let monthWidth = (containerSize.width - 32 - 40) / 3 // 3 columns with spacing
        let monthHeight: CGFloat = 150 // Approximate height
        
        let monthCenterX = 16 + monthWidth * CGFloat(col) + monthWidth / 2 + CGFloat(col) * 20
        let monthCenterY = 40 + monthHeight * CGFloat(row) + monthHeight / 2 + CGFloat(row) * 24
        
        // Calculate offset to center the month
        let screenCenterX = containerSize.width / 2
        let screenCenterY = (containerSize.height - 120) / 2
        
        let offsetX = screenCenterX - monthCenterX
        let offsetY = screenCenterY - monthCenterY
        
        // Set zoom scale to fill screen with the month
        let targetScale: CGFloat = 4.2
        
        // Phase 1: Start zooming with smooth bezier curve
        withAnimation(.timingCurve(0.32, 0, 0.24, 1, duration: 0.8)) {
            zoomScale = targetScale
            zoomOffset = CGSize(width: offsetX * targetScale, height: offsetY * targetScale)
        }
        
        // Phase 2: Switch view at 70% of the animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.56) {
            viewMode = .month
        }
        
        // Phase 3: Complete the transition with matching curve
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.58) {
            withAnimation(.timingCurve(0.32, 0, 0.24, 1, duration: 0.4)) {
                zoomScale = 1.0
                zoomOffset = .zero
            }
            
            // Reset flags after full animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                navigatedViaZoom = false
                selectedMonthForZoom = nil
            }
        }
    }
    
    private var year: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    private var yearDates: [Date] {
        let calendar = Calendar.current
        let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let endOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!
        
        var dates: [Date] = []
        var currentDate = startOfYear
        
        while currentDate <= endOfYear {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    private var datesByMonth: [[Date]] {
        let calendar = Calendar.current
        var monthArrays: [[Date]] = Array(repeating: [], count: 12)
        
        for date in yearDates {
            let month = calendar.component(.month, from: date) - 1
            if month >= 0 && month < 12 {
                monthArrays[month].append(date)
            }
        }
        
        return monthArrays
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack(alignment: .leading, spacing: 24) {
                    // Row 1 - Jan, Feb, Mar
                    HStack(alignment: .top, spacing: 20) {
                        ForEach(0..<3) { col in
                            MonthDotGrid(
                                dates: datesByMonth[col],
                                monthIndex: col,
                                viewModel: viewModel,
                                selectedDate: $selectedDate,
                                hoveredDate: $hoveredDate,
                                accentColor: accentColor,
                                dotSize: 10,
                                spacing: 10,
                                tintedBackgrounds: tintedBackgrounds,
                                colorScheme: colorScheme,
                                animationNamespace: animationNamespace,
                                isZooming: selectedMonthForZoom == col,
                                selectedMonthForZoom: selectedMonthForZoom,
                                onTap: {
                                    let calendar = Calendar.current
                                    let year = calendar.component(.year, from: Date())
                                    if let monthDate = calendar.date(from: DateComponents(year: year, month: col + 1, day: 1)) {
                                        currentMonth = monthDate
                                        calculateZoomParameters(for: col)
                                        HapticsManager.shared.impact(.soft)
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
                                hoveredDate: $hoveredDate,
                                accentColor: accentColor,
                                dotSize: 10,
                                spacing: 10,
                                tintedBackgrounds: tintedBackgrounds,
                                colorScheme: colorScheme,
                                animationNamespace: animationNamespace,
                                isZooming: selectedMonthForZoom == monthIndex,
                                selectedMonthForZoom: selectedMonthForZoom,
                                onTap: {
                                    let calendar = Calendar.current
                                    let year = calendar.component(.year, from: Date())
                                    if let monthDate = calendar.date(from: DateComponents(year: year, month: monthIndex + 1, day: 1)) {
                                        currentMonth = monthDate
                                        calculateZoomParameters(for: monthIndex)
                                        HapticsManager.shared.impact(.soft)
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
                                hoveredDate: $hoveredDate,
                                accentColor: accentColor,
                                dotSize: 10,
                                spacing: 10,
                                tintedBackgrounds: tintedBackgrounds,
                                colorScheme: colorScheme,
                                animationNamespace: animationNamespace,
                                isZooming: selectedMonthForZoom == monthIndex,
                                selectedMonthForZoom: selectedMonthForZoom,
                                onTap: {
                                    let calendar = Calendar.current
                                    let year = calendar.component(.year, from: Date())
                                    if let monthDate = calendar.date(from: DateComponents(year: year, month: monthIndex + 1, day: 1)) {
                                        currentMonth = monthDate
                                        calculateZoomParameters(for: monthIndex)
                                        HapticsManager.shared.impact(.soft)
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
                                hoveredDate: $hoveredDate,
                                accentColor: accentColor,
                                dotSize: 10,
                                spacing: 10,
                                tintedBackgrounds: tintedBackgrounds,
                                colorScheme: colorScheme,
                                animationNamespace: animationNamespace,
                                isZooming: selectedMonthForZoom == monthIndex,
                                selectedMonthForZoom: selectedMonthForZoom,
                                onTap: {
                                    let calendar = Calendar.current
                                    let year = calendar.component(.year, from: Date())
                                    if let monthDate = calendar.date(from: DateComponents(year: year, month: monthIndex + 1, day: 1)) {
                                        currentMonth = monthDate
                                        calculateZoomParameters(for: monthIndex)
                                        HapticsManager.shared.impact(.soft)
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
            }
        }
    }
}

struct MonthDotGrid: View {
    let dates: [Date]
    let monthIndex: Int
    let viewModel: PositiveNoteViewModel
    @Binding var selectedDate: Date?
    @Binding var hoveredDate: Date?
    let accentColor: Color
    let dotSize: CGFloat
    let spacing: CGFloat
    let tintedBackgrounds: Bool
    let colorScheme: ColorScheme?
    let animationNamespace: Namespace.ID
    let isZooming: Bool
    let selectedMonthForZoom: Int?
    let onTap: () -> Void
    
    private let dotsPerRow = 5 // 5 dots per row for better space utilization
    
    var body: some View {
        VStack(spacing: spacing) {
            // Create rows of dots
            ForEach(0..<numberOfRows, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<dotsPerRow, id: \.self) { col in
                        let index = row * dotsPerRow + col
                        if index < dates.count {
                            let date = dates[index]
                            let calendar = Calendar.current
                            let today = Date()
                            let isToday = calendar.isDateInToday(date)
                            let isFutureDay = date > today
                            
                            DayDotView(
                                date: date,
                                hasNote: viewModel.hasNoteForDate(date),
                                isToday: isToday,
                                isFuture: isFutureDay,
                                accentColor: accentColor,
                                isHovered: hoveredDate == date,
                                dotSize: dotSize, // Full size dots
                                tintedBackgrounds: tintedBackgrounds,
                                colorScheme: colorScheme
                            )
                            .allowsHitTesting(false) // Disable individual dot taps
                            .onHover { hovering in
                                hoveredDate = hovering ? date : nil
                            }
                        } else {
                            // Empty space for missing days
                            Circle()
                                .fill(Color.clear)
                                .frame(width: dotSize, height: dotSize)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.black.opacity(0.001)) // Invisible background to ensure tap area
        .scaleEffect(isZooming ? 1.02 : 1.0) // Subtle scale for feedback
        .opacity(isZooming ? 1.0 : (selectedMonthForZoom != nil ? 0.7 : 1.0)) // Fade non-selected months during zoom
        .contentShape(Rectangle()) // Make entire area tappable
        .matchedGeometryEffect(id: "month-\(monthIndex)", in: animationNamespace)
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
            Circle()
                .fill(dotColor)
                .frame(width: dotSize, height: dotSize)
                .scaleEffect(animateIn ? 1 : 0.3)
                .opacity(animateIn ? 1 : 0)
            
            if hasNote {
                Image(systemName: "checkmark")
                    .font(.system(size: max(dotSize * 0.5, 8), weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(animateIn ? 1 : 0)
            }
            
            if isToday {
                Circle()
                    .stroke(accentColor, lineWidth: max(dotSize * 0.125, 2))
                    .frame(width: dotSize + 4, height: dotSize + 4)
            }
        }
        .scaleEffect(isHovered ? 1.3 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
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

// Helper extension
extension Date {
    var isFuture: Bool {
        self > Date()
    }
}