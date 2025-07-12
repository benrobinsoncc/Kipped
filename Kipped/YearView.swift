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
    let accentColor: Color
    let selectedFont: FontOption
    let tintedBackgrounds: Bool
    let colorScheme: ColorScheme?
    
    @State private var hoveredDate: Date?
    
    private let dotSize: CGFloat = 10
    private let spacing: CGFloat = 10
    private let monthGap: CGFloat = 24
    
    private var year: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    private var yearDates: [Date] {
        return (0..<365).map { dayIndex in
            viewModel.dateForDay(dayIndex)
        }
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
                                viewModel: viewModel,
                                selectedDate: $selectedDate,
                                hoveredDate: $hoveredDate,
                                accentColor: accentColor,
                                dotSize: 10,
                                spacing: 10,
                                tintedBackgrounds: tintedBackgrounds,
                                colorScheme: colorScheme
                            )
                        }
                    }
                    
                    // Row 2 - Apr, May, Jun
                    HStack(alignment: .top, spacing: 20) {
                        ForEach(3..<6) { monthIndex in
                            MonthDotGrid(
                                dates: datesByMonth[monthIndex],
                                viewModel: viewModel,
                                selectedDate: $selectedDate,
                                hoveredDate: $hoveredDate,
                                accentColor: accentColor,
                                dotSize: 10,
                                spacing: 10,
                                tintedBackgrounds: tintedBackgrounds,
                                colorScheme: colorScheme
                            )
                        }
                    }
                    
                    // Row 3 - Jul, Aug, Sep
                    HStack(alignment: .top, spacing: 20) {
                        ForEach(6..<9) { monthIndex in
                            MonthDotGrid(
                                dates: datesByMonth[monthIndex],
                                viewModel: viewModel,
                                selectedDate: $selectedDate,
                                hoveredDate: $hoveredDate,
                                accentColor: accentColor,
                                dotSize: 10,
                                spacing: 10,
                                tintedBackgrounds: tintedBackgrounds,
                                colorScheme: colorScheme
                            )
                        }
                    }
                    
                    // Row 4 - Oct, Nov, Dec
                    HStack(alignment: .top, spacing: 20) {
                        ForEach(9..<12) { monthIndex in
                            MonthDotGrid(
                                dates: datesByMonth[monthIndex],
                                viewModel: viewModel,
                                selectedDate: $selectedDate,
                                hoveredDate: $hoveredDate,
                                accentColor: accentColor,
                                dotSize: 10,
                                spacing: 10,
                                tintedBackgrounds: tintedBackgrounds,
                                colorScheme: colorScheme
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
    let viewModel: PositiveNoteViewModel
    @Binding var selectedDate: Date?
    @Binding var hoveredDate: Date?
    let accentColor: Color
    let dotSize: CGFloat
    let spacing: CGFloat
    let tintedBackgrounds: Bool
    let colorScheme: ColorScheme?
    
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
                            .onTapGesture {
                                if !isFutureDay {
                                    selectedDate = date
                                    HapticsManager.shared.impact(.soft)
                                }
                            }
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
        .frame(maxWidth: .infinity, alignment: .top)
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
    
    @State private var animateIn = false
    
    init(date: Date, hasNote: Bool, isToday: Bool, isFuture: Bool, accentColor: Color, isHovered: Bool, dotSize: CGFloat = 16, tintedBackgrounds: Bool, colorScheme: ColorScheme?) {
        self.date = date
        self.hasNote = hasNote
        self.isToday = isToday
        self.isFuture = isFuture
        self.accentColor = accentColor
        self.isHovered = isHovered
        self.dotSize = dotSize
        self.tintedBackgrounds = tintedBackgrounds
        self.colorScheme = colorScheme
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
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(Double.random(in: 0...0.5))) {
                animateIn = true
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