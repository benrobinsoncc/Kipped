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
    @Binding var currentMonth: Date
    let accentColor: Color
    let selectedFont: FontOption
    let tintedBackgrounds: Bool
    let colorScheme: ColorScheme?
    
    private let dotSize: CGFloat = 16
    private let spacing: CGFloat = 6
    
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
    
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - 32 // Account for padding
            let dotsPerRow = Int(availableWidth / (dotSize + spacing))
            let totalRows = Int(ceil(Double(monthDates.count) / Double(dotsPerRow)))
            let gridHeight = CGFloat(totalRows) * (dotSize + spacing) - spacing
            
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: dotsPerRow), spacing: spacing) {
                    ForEach(Array(monthDates.enumerated()), id: \.element) { dayIndex, date in
                        let daysSinceOnboarding = viewModel.daysSinceOnboarding()
                        let onboardingDate = viewModel.onboardingDate
                        let daysSinceOnboardingForDate = Calendar.current.dateComponents([.day], from: onboardingDate, to: date).day ?? 0
                        let isCurrentDay = Calendar.current.isDateInToday(date)
                        let isFutureDay = date > Date()
                        
                        DayDotView(
                            date: date,
                            hasNote: viewModel.hasNoteForDate(date),
                            isToday: isCurrentDay,
                            isFuture: isFutureDay,
                            accentColor: accentColor,
                            isHovered: false
                        )
                        .onTapGesture {
                            if !isFutureDay {
                                selectedDate = date
                                HapticsManager.shared.impact(.soft)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .frame(minHeight: min(gridHeight, geometry.size.height))
            }
        }
    }
}

