//
//  MemoriesView.swift
//  Kipped
//
//  Created by Assistant on 14/07/2025.
//

import SwiftUI

struct MemoriesView: View {
    @StateObject private var viewModel: PositiveNoteViewModel
    @Binding var accentColor: Color
    @Binding var selectedFont: FontOption
    @Binding var tintedBackgrounds: Bool
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    @State private var selectedPeriod: MemoryPeriod = .weekly
    @State private var currentDate = Date()
    
    enum MemoryPeriod: String, CaseIterable {
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
        
        var icon: String {
            switch self {
            case .weekly: return "calendar.day.timeline.left"
            case .monthly: return "calendar"
            case .yearly: return "calendar.circle"
            }
        }
    }
    
    init(viewModel: PositiveNoteViewModel, accentColor: Binding<Color>, selectedFont: Binding<FontOption>, tintedBackgrounds: Binding<Bool>) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._accentColor = accentColor
        self._selectedFont = selectedFont
        self._tintedBackgrounds = tintedBackgrounds
    }
    
    private var tintedBackground: Color {
        Color.tintedBackground(accentColor: accentColor, isEnabled: tintedBackgrounds, colorScheme: colorScheme)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                tintedBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Period selector
                    Picker("Memory Period", selection: $selectedPeriod) {
                        ForEach(MemoryPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue)
                                .tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 6)
                    
                    // Memory cards grid with fade effect
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                            ForEach(getMemoryDates(), id: \.self) { date in
                                MemoryCard(
                                    date: date,
                                    period: selectedPeriod,
                                    notes: getNotesForPeriod(date: date),
                                    accentColor: accentColor,
                                    selectedFont: selectedFont,
                                    colorScheme: colorScheme
                                )
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                            }
                        }
                        .padding()
                        .padding(.bottom, 60) // Extra bottom padding for fade
                    }
                    .mask(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.black, location: 0.0),
                                .init(color: Color.black, location: 0.85),
                                .init(color: Color.black.opacity(0.3), location: 0.95),
                                .init(color: Color.clear, location: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .navigationTitle("Memories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.secondary.opacity(0.15))
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: "xmark")
                                .foregroundColor(.secondary.opacity(0.7))
                                .font(.system(size: 11, weight: .bold))
                        }
                    }
                }
            }
        }
    }
    
    private func getMemoryDates() -> [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        
        switch selectedPeriod {
        case .weekly:
            // Get last 12 weeks
            for weekOffset in 0..<12 {
                if let weekDate = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: currentDate) {
                    dates.append(weekDate)
                }
            }
        case .monthly:
            // Get last 12 months
            for monthOffset in 0..<12 {
                if let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: currentDate) {
                    dates.append(monthDate)
                }
            }
        case .yearly:
            // Get last 5 years
            for yearOffset in 0..<5 {
                if let yearDate = calendar.date(byAdding: .year, value: -yearOffset, to: currentDate) {
                    dates.append(yearDate)
                }
            }
        }
        
        return dates
    }
    
    private func getNotesForPeriod(date: Date) -> [PositiveNote] {
        let calendar = Calendar.current
        let startDate: Date
        let endDate: Date
        
        switch selectedPeriod {
        case .weekly:
            startDate = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
            endDate = calendar.dateInterval(of: .weekOfYear, for: date)?.end ?? date
        case .monthly:
            startDate = calendar.dateInterval(of: .month, for: date)?.start ?? date
            endDate = calendar.dateInterval(of: .month, for: date)?.end ?? date
        case .yearly:
            startDate = calendar.dateInterval(of: .year, for: date)?.start ?? date
            endDate = calendar.dateInterval(of: .year, for: date)?.end ?? date
        }
        
        return viewModel.notes.filter { note in
            note.date >= startDate && note.date < endDate
        }
    }
}

struct MemoryCard: View {
    let date: Date
    let period: MemoriesView.MemoryPeriod
    let notes: [PositiveNote]
    let accentColor: Color
    let selectedFont: FontOption
    let colorScheme: ColorScheme?
    
    @State private var isFlipped = false
    @State private var rotation: Double = 0
    @State private var memorySummary: OpenAIService.MemorySummary?
    @State private var isLoadingSummary = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        switch period {
        case .weekly:
            formatter.dateFormat = "MMM d"
        case .monthly:
            formatter.dateFormat = "MMMM yyyy"
        case .yearly:
            formatter.dateFormat = "yyyy"
        }
        return formatter
    }
    
    private var periodLabel: String {
        switch period {
        case .weekly:
            return "Week of"
        case .monthly:
            return ""
        case .yearly:
            return "Year"
        }
    }
    
    private var cardGradient: LinearGradient {
        var baseColor = notes.isEmpty ? Color.gray : accentColor
        
        // Use AI-suggested color if available
        if let colorHex = memorySummary?.colorSuggestion,
           let color = Color(hex: colorHex) {
            baseColor = color
        }
        
        return LinearGradient(
            gradient: Gradient(colors: [
                baseColor.opacity(0.1),
                baseColor.opacity(0.05),
                baseColor.opacity(0.02)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var stampDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date).uppercased()
    }
    
    var body: some View {
        ZStack {
            // Back of postcard (when flipped)
            if abs(rotation.truncatingRemainder(dividingBy: 360)) > 90 && abs(rotation.truncatingRemainder(dividingBy: 360)) < 270 {
                postcardBack
                    .rotation3DEffect(
                        .degrees(180),
                        axis: (x: 0, y: 1, z: 0)
                    )
            } else {
                // Front of postcard
                postcardFront
            }
        }
        .rotation3DEffect(
            .degrees(rotation),
            axis: (x: 0, y: 1, z: 0)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                if isFlipped {
                    rotation -= 180
                } else {
                    rotation += 180
                }
                isFlipped.toggle()
            }
            HapticsManager.shared.impact(.soft)
        }
        .onAppear {
            loadAISummary()
        }
    }
    
    private func loadAISummary() {
        // Check if AI summaries are enabled
        let enableAI = UserDefaults.standard.bool(forKey: "enableAISummaries")
        guard enableAI, !notes.isEmpty && memorySummary == nil && !isLoadingSummary else { return }
        
        isLoadingSummary = true
        Task {
            do {
                let provider = UserDefaults.standard.string(forKey: "aiProvider") ?? "openai"
                let summary: OpenAIService.MemorySummary
                if provider == "anthropic" {
                    summary = try await ClaudeService.shared.generateMemorySummary(
                        for: notes,
                        period: period,
                        date: date
                    )
                } else {
                    summary = try await OpenAIService.shared.generateMemorySummary(
                        for: notes,
                        period: period,
                        date: date
                    )
                }
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.memorySummary = summary
                        self.isLoadingSummary = false
                    }
                }
            } catch {
                print("Failed to generate AI summary: \(error)")
                await MainActor.run {
                    self.isLoadingSummary = false
                }
            }
        }
    }
    
    private var postcardFront: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Postcard header with stamp
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    if !periodLabel.isEmpty {
                        Text(periodLabel)
                            .appFont(selectedFont)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Text(dateFormatter.string(from: date))
                        .appFont(selectedFont)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Postage stamp
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(accentColor.opacity(0.8))
                        .frame(width: 60, height: 70)
                    
                    VStack(spacing: 2) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                        
                        Text(notes.count > 0 ? "\(notes.count)" : "0")
                            .appFont(selectedFont)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("MOMENTS")
                            .font(.system(size: 6, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .overlay(
                    // Perforated edge effect
                    GeometryReader { geo in
                        Path { path in
                            let dotSize: CGFloat = 2
                            let spacing: CGFloat = 4
                            let count = Int(geo.size.height / spacing)
                            
                            for i in 0..<count {
                                let y = CGFloat(i) * spacing + dotSize
                                path.addEllipse(in: CGRect(x: -dotSize/2, y: y - dotSize/2, width: dotSize, height: dotSize))
                                path.addEllipse(in: CGRect(x: geo.size.width - dotSize/2, y: y - dotSize/2, width: dotSize, height: dotSize))
                            }
                        }
                        .fill(Color.white.opacity(0.3))
                    }
                )
            }
            .padding()
            
            Divider()
                .overlay(
                    // Dashed line effect
                    GeometryReader { geo in
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: geo.size.height/2))
                            path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height/2))
                        }
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
                        .foregroundColor(.secondary.opacity(0.3))
                    }
                )
            
            // Content area
            if notes.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 30))
                        .foregroundColor(.secondary.opacity(0.3))
                    Text("No memories yet")
                        .appFont(selectedFont)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    // AI Summary or loading state
                    if isLoadingSummary {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Creating memory...")
                                .appFont(selectedFont)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    } else if let summary = memorySummary {
                        // AI-generated title
                        Text(summary.title)
                            .appFont(selectedFont)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        // AI-generated summary
                        Text(summary.summary)
                            .appFont(selectedFont)
                            .font(.caption)
                            .foregroundColor(.primary.opacity(0.8))
                            .lineLimit(3)
                            .padding(.vertical, 2)
                        
                        // Themes
                        if !summary.themes.isEmpty {
                            HStack(spacing: 6) {
                                ForEach(summary.themes, id: \.self) { theme in
                                    Text(theme)
                                        .appFont(selectedFont)
                                        .font(.system(size: 10))
                                        .foregroundColor(accentColor)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(accentColor.opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                        }
                    } else {
                        // Fallback to simple display
                        Text(generateTitle())
                            .appFont(selectedFont)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        // Preview of moments
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(notes.prefix(2)) { note in
                                HStack(alignment: .top, spacing: 4) {
                                    Text("•")
                                        .foregroundColor(accentColor)
                                    Text(note.content)
                                        .appFont(selectedFont)
                                        .font(.caption)
                                        .lineLimit(2)
                                        .foregroundColor(.primary.opacity(0.8))
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .background(
            ZStack {
                // Base background
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                
                // Gradient overlay
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardGradient)
                
                // Texture overlay
                RoundedRectangle(cornerRadius: 12)
                    .stroke(accentColor.opacity(0.1), lineWidth: 1)
            }
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .overlay(
            // Postmark overlay
            Text(stampDate)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(accentColor.opacity(0.3))
                .rotationEffect(.degrees(-12))
                .position(x: 80, y: 60)
        )
    }
    
    private var postcardBack: some View {
        VStack(spacing: 12) {
            // All notes
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("All Moments")
                        .appFont(selectedFont)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ForEach(notes) { note in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(formatDate(note.date))
                                .appFont(selectedFont)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text(note.content)
                                .appFont(selectedFont)
                                .font(.caption)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical, 4)
                        
                        if note.id != notes.last?.id {
                            Divider()
                        }
                    }
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private func generateTitle() -> String {
        // Placeholder for AI summary - for now, generate a simple title
        let themes = ["Gratitude", "Joy", "Growth", "Peace", "Love", "Strength", "Hope"]
        let theme = themes.randomElement() ?? "Memories"
        
        switch period {
        case .weekly:
            return "A Week of \(theme)"
        case .monthly:
            return "\(theme) & Moments"
        case .yearly:
            return "Year of \(theme)"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}