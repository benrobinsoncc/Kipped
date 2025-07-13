//
//  MonthView.swift
//  Kipped
//
//  Created by Ben Robinson on 28/06/2025.
//

import SwiftUI

struct MonthView: View {
    @ObservedObject var viewModel: PositiveNoteViewModel
    @Binding var selectedDate: Date?
    @Binding var selectedNote: PositiveNote?
    @Binding var currentMonth: Date
    let accentColor: Color
    let selectedFont: FontOption
    let tintedBackgrounds: Bool
    let colorScheme: ColorScheme?
    let animationNamespace: Namespace.ID
    let skipAnimation: Bool
    
    @State private var hoveredDate: Date?
    @Environment(\.dragHandler) private var dragHandler
    @Environment(\.dragEndHandler) private var dragEndHandler
    
    private let dotsPerRow = 5 // Same as YearView's MonthDotGrid
    
    private var monthDates: [Date] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)!.start
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        
        var dates: [Date] = []
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    private func calculateOptimalDotSize(availableWidth: CGFloat, availableHeight: CGFloat) -> (dotSize: CGFloat, spacing: CGFloat) {
        let totalRows = Int(ceil(Double(monthDates.count) / Double(dotsPerRow)))
        
        // Fixed spacing for consistent layout
        let spacing: CGFloat = 12
        
        // Calculate dot size to fit the available space with spacing
        let totalHorizontalSpacing = CGFloat(dotsPerRow - 1) * spacing
        let totalVerticalSpacing = CGFloat(totalRows - 1) * spacing
        
        let dotSizeForWidth = (availableWidth - totalHorizontalSpacing) / CGFloat(dotsPerRow)
        let dotSizeForHeight = (availableHeight - totalVerticalSpacing) / CGFloat(totalRows)
        
        // Use the smaller of the two to ensure it fits
        let dotSize = min(dotSizeForWidth, dotSizeForHeight, 50) // Cap at 50 for cleaner look
        
        return (dotSize: max(dotSize, 16), spacing: spacing) // Minimum dot size of 16
    }
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let availableHeight = geometry.size.height - 40 // Account for vertical padding
            let layout = calculateOptimalDotSize(availableWidth: availableWidth - 48, availableHeight: availableHeight)
            
            VStack {
                VStack(spacing: layout.spacing) {
                    // Create rows of dots
                    ForEach(0..<numberOfRows, id: \.self) { row in
                        HStack(spacing: layout.spacing) {
                            ForEach(0..<dotsPerRow, id: \.self) { col in
                                let index = row * dotsPerRow + col
                                if index < monthDates.count {
                                    let date = monthDates[index]
                                    let isCurrentDay = Calendar.current.isDateInToday(date)
                                    let isFutureDay = date > Date()
                                    
                                    DayDotView(
                                        date: date,
                                        hasNote: viewModel.hasNoteForDate(date),
                                        isToday: isCurrentDay,
                                        isFuture: isFutureDay,
                                        accentColor: accentColor,
                                        isHovered: hoveredDate == date,
                                        dotSize: layout.dotSize,
                                        tintedBackgrounds: tintedBackgrounds,
                                        colorScheme: colorScheme,
                                        skipAnimation: skipAnimation
                                    )
                                    .frame(width: layout.dotSize, height: layout.dotSize)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if !isFutureDay {
                                            // Check if there's an existing note for this date
                                            if let existingNote = viewModel.getNoteForDate(date) {
                                                selectedNote = existingNote
                                            } else {
                                                selectedNote = nil
                                            }
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
                                        .frame(width: layout.dotSize, height: layout.dotSize)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24) // Updated to 24pt margins
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .matchedGeometryEffect(id: "month-\(monthIndex)", in: animationNamespace)
                
                Spacer()
            }
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        dragHandler?(value.location)
                    }
                    .onEnded { _ in
                        dragEndHandler?()
                    }
            )
        }
    }
    
    private var monthIndex: Int {
        let calendar = Calendar.current
        return calendar.component(.month, from: currentMonth) - 1
    }
    
    private var numberOfRows: Int {
        Int(ceil(Double(monthDates.count) / Double(dotsPerRow)))
    }
}

