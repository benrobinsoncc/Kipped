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
    
    private let dotSize: CGFloat = 12
    private let spacing: CGFloat = 8
    
    private var year: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    private var yearDates: [Date] {
        return (0..<365).map { dayIndex in
            viewModel.dateForDay(dayIndex)
        }
    }
    
    private var daysInYear: Int {
        let calendar = Calendar.current
        let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let endOfYear = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1))!
        return calendar.dateComponents([.day], from: startOfYear, to: endOfYear).day!
    }
    
    private func calculateOptimalDotsPerRow(maxDotsPerRow: Int, maxRows: Int) -> Int {
        // Target 13 dots per row, but ensure we can fit all 365 dots
        let targetDotsPerRow = 13
        let actualDotsPerRow = min(targetDotsPerRow, maxDotsPerRow)
        let requiredRows = Int(ceil(365.0 / Double(actualDotsPerRow)))
        
        // If we can fit the required rows, use the target
        if requiredRows <= maxRows {
            return actualDotsPerRow
        }
        
        // Otherwise, calculate minimum needed to fit all dots
        return max(actualDotsPerRow, Int(ceil(365.0 / Double(maxRows))))
    }
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - 32 // Match MonthView padding
            let availableHeight = geometry.size.height - 40 // Match MonthView padding
            
            // Calculate optimal grid layout to fill vertical space
            let maxDotsPerRow = max(1, Int(availableWidth / (dotSize + spacing)))
            let maxRows = max(1, Int(availableHeight / (dotSize + spacing)))
            
            // Find the best combination of rows and columns to fit 365 dots
            let bestDotsPerRow = calculateOptimalDotsPerRow(maxDotsPerRow: maxDotsPerRow, maxRows: maxRows)
            let bestRows = Int(ceil(365.0 / Double(bestDotsPerRow)))
            let gridHeight = CGFloat(bestRows) * (dotSize + spacing) - spacing
            
            VStack {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: bestDotsPerRow), spacing: spacing) {
                    ForEach(Array(yearDates.enumerated()), id: \.element) { dayIndex, date in
                        let daysSinceOnboarding = viewModel.daysSinceOnboarding()
                        let isCurrentDay = dayIndex == daysSinceOnboarding
                        let isFutureDay = dayIndex > daysSinceOnboarding
                        
                        DayDotView(
                            date: date,
                            hasNote: viewModel.hasNoteForDate(date),
                            isToday: isCurrentDay,
                            isFuture: isFutureDay,
                            accentColor: accentColor,
                            isHovered: hoveredDate == date,
                            dotSize: dotSize,
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
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
        }
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