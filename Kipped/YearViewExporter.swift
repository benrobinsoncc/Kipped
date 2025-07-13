//
//  YearViewExporter.swift
//  Kipped
//
//  Created by Assistant on 13/07/2025.
//

import SwiftUI
import UIKit

struct YearViewExporter {
    @MainActor
    static func exportYearView(
        viewModel: PositiveNoteViewModel,
        accentColor: Color,
        selectedFont: FontOption,
        tintedBackgrounds: Bool,
        colorScheme: ColorScheme?
    ) -> UIImage? {
        let year = Calendar.current.component(.year, from: Date())
        let capturedDays = viewModel.notes.count
        
        let exportView = YearExportView(
            viewModel: viewModel,
            year: year,
            capturedDays: capturedDays,
            accentColor: accentColor,
            selectedFont: selectedFont,
            tintedBackgrounds: tintedBackgrounds,
            colorScheme: colorScheme
        )
        
        if #available(iOS 16.0, *) {
            // Create the image using ImageRenderer (iOS 16+)
            let renderer = ImageRenderer(content: exportView)
            renderer.scale = UIScreen.main.scale
            return renderer.uiImage
        } else {
            // Fallback for iOS 15 and earlier
            let controller = UIHostingController(rootView: exportView)
            let targetSize = CGSize(width: 1080, height: 1920)
            
            // Set up the controller
            controller.view.frame = CGRect(origin: .zero, size: targetSize)
            controller.view.backgroundColor = colorScheme == .dark ? .black : .white
            
            // Force layout
            controller.view.setNeedsLayout()
            controller.view.layoutIfNeeded()
            
            // Create a temporary window for proper rendering
            let window = UIWindow(frame: CGRect(origin: .zero, size: targetSize))
            window.rootViewController = controller
            window.isHidden = false
            window.makeKeyAndVisible()
            
            // Render the image
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            let image = renderer.image { context in
                controller.view.layer.render(in: context.cgContext)
            }
            
            // Clean up
            window.resignKey()
            window.isHidden = true
            window.rootViewController = nil
            
            return image
        }
    }
}

struct YearExportView: View {
    @ObservedObject var viewModel: PositiveNoteViewModel
    let year: Int
    let capturedDays: Int
    let accentColor: Color
    let selectedFont: FontOption
    let tintedBackgrounds: Bool
    let colorScheme: ColorScheme?
    
    private let monthNames = ["January", "February", "March", "April", "May", "June", 
                             "July", "August", "September", "October", "November", "December"]
    private let monthLetters = ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"]
    
    var body: some View {
        ZStack {
            // Background
            (colorScheme == .dark ? Color.black : Color.white)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with captured days
                HStack(spacing: 0) {
                    Text("\(capturedDays)")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(accentColor)
                    Text(" positive days in ")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text(String(year))
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(accentColor)
                }
                .padding(.top, 100)
                .padding(.bottom, 95)
                
                // Simple year grid
                VStack(spacing: 55) {
                    ForEach(0..<4) { row in
                        HStack(spacing: 55) {
                            ForEach(0..<3) { col in
                                let monthIndex = row * 3 + col
                                MonthExportView(
                                    monthIndex: monthIndex,
                                    monthLetter: monthLetters[monthIndex],
                                    viewModel: viewModel,
                                    year: year,
                                    accentColor: accentColor,
                                    colorScheme: colorScheme
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 50)
                
                Spacer(minLength: 40)
                
                // App branding
                Text("Kipped")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.bottom, 80)
            }
        }
        .frame(width: 1080, height: 1920)
    }
}

struct MonthExportView: View {
    let monthIndex: Int
    let monthLetter: String
    let viewModel: PositiveNoteViewModel
    let year: Int
    let accentColor: Color
    let colorScheme: ColorScheme?
    
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
    
    private func celebratoryIcon(for day: Int) -> String {
        let index = (day + monthIndex + 1) % celebratoryIcons.count
        return celebratoryIcons[index]
    }
    
    private var daysInMonth: Int {
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: year, month: monthIndex + 1))!
        return calendar.range(of: .day, in: .month, for: date)?.count ?? 30
    }
    
    private var notesInMonth: Set<Int> {
        let calendar = Calendar.current
        let noteDays = viewModel.notes.compactMap { note -> Int? in
            let components = calendar.dateComponents([.year, .month, .day], from: note.date)
            if components.year == year && components.month == monthIndex + 1 {
                return components.day
            }
            return nil
        }
        return Set(noteDays)
    }
    
    private var today: (day: Int, month: Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month], from: Date())
        return (components.day ?? 0, components.month ?? 0)
    }
    
    private func isToday(_ day: Int) -> Bool {
        today.month == monthIndex + 1 && today.day == day
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Month dots
            VStack(spacing: 14) {
                ForEach(0..<7) { row in
                    HStack(spacing: 14) {
                        ForEach(0..<5) { col in
                            let dayNumber = row * 5 + col + 1
                            if dayNumber <= daysInMonth {
                                ZStack {
                                    if notesInMonth.contains(dayNumber) {
                                        // Show celebratory icon for completed days
                                        Image(systemName: celebratoryIcon(for: dayNumber))
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(accentColor)
                                    } else {
                                        // Show circle for incomplete days
                                        Circle()
                                            .fill(Color.gray.opacity(0.15))
                                            .frame(width: 18, height: 18)
                                    }
                                    
                                    // Today indicator
                                    if isToday(dayNumber) {
                                        Circle()
                                            .stroke(accentColor, lineWidth: 2.5)
                                            .frame(width: 24, height: 24)
                                    }
                                }
                                .frame(width: 28, height: 28)
                            } else {
                                Color.clear
                                    .frame(width: 28, height: 28)
                            }
                        }
                    }
                }
            }
            
            // Month label
            Text(monthLetter)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(accentColor)
        }
    }
}

// Activity view controller wrapper
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}