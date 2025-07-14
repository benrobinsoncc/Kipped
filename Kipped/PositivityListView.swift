//
//  PositivityListView.swift
//  Kipped
//
//  Created by Ben Robinson on 28/06/2025.
//

import SwiftUI

struct PositivityListView: View {
    @ObservedObject var viewModel: PositiveNoteViewModel
    @Binding var selectedNote: PositiveNote?
    @Binding var showingAddNote: Bool
    let accentColor: Color
    let selectedFont: FontOption
    let tintedBackgrounds: Bool
    let colorScheme: ColorScheme?
    
    @Environment(\.dragHandler) private var dragHandler
    @Environment(\.dragEndHandler) private var dragEndHandler
    
    private var tintedSecondaryBackground: Color {
        Color.tintedSecondaryBackground(accentColor: accentColor, isEnabled: tintedBackgrounds, colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.notes.isEmpty {
                EmptyPositivityView(selectedFont: selectedFont, accentColor: accentColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // All notes in one continuous timeline, filtering out empty ones
                        let allNotes = viewModel.notes
                            .filter { !$0.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                            .sorted(by: { $0.date > $1.date })
                        ForEach(Array(allNotes.enumerated()), id: \.element.id) { index, note in
                            PositiveNoteCard(
                                note: note,
                                viewModel: viewModel,
                                onTap: {
                                    selectedNote = note
                                    showingAddNote = true
                                },
                                accentColor: accentColor,
                                selectedFont: selectedFont,
                                tintedBackgrounds: tintedBackgrounds,
                                colorScheme: colorScheme,
                                isNewlyCreated: viewModel.lastCreatedNoteId == note.id,
                                showConnectingLine: index < allNotes.count - 1
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.top, 16)
                    
                    // Bottom spacing to allow content to scroll into fade zone
                    Color.clear.frame(height: 200)
                }
            }
        }
        .padding(.top, 40) // Match spacing with YearView and MonthView
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
    
    private var sortedMonthGroups: [(key: Date, value: [PositiveNote])] {
        viewModel.notesGroupedByMonth.sorted { $0.key > $1.key }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

struct PositiveNoteCard: View {
    let note: PositiveNote
    @ObservedObject var viewModel: PositiveNoteViewModel
    let onTap: () -> Void
    let accentColor: Color
    let selectedFont: FontOption
    let tintedBackgrounds: Bool
    let colorScheme: ColorScheme?
    let isNewlyCreated: Bool
    let showConnectingLine: Bool
    
    @State private var isPressed = false
    @State private var shimmerOffset: CGFloat = -100
    
    // Computed property to clean up note content for display
    private var displayContent: String {
        // Split by newlines and filter out empty lines
        let lines = note.content
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        // Join non-empty lines with single newlines
        return lines.joined(separator: "\n")
    }
    
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
    
    private var dateString: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(note.date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(note.date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMM d"
            return formatter.string(from: note.date)
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline indicator
            ZStack(alignment: .top) {
                // Connecting line (behind icon)
                if showConnectingLine {
                    Rectangle()
                        .fill(accentColor.opacity(0.2))
                        .frame(width: 1)
                        .offset(y: 16)
                }
                
                // Icon indicator
                Image(systemName: celebratoryIcon(for: note.date))
                    .font(.system(size: 12))
                    .foregroundColor(accentColor)
                    .frame(width: 16, height: 16)
                    .background(Color(UIColor.systemBackground))
            }
            .frame(width: 16)
            
            // Content
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dateString)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(displayContent)
                        .appFont(selectedFont)
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.12)) {
                    isPressed = pressing
                }
            }, perform: {})
            .overlay(
                // Shimmer effect for newly created notes
                Group {
                    if isNewlyCreated {
                        GeometryReader { geometry in
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.clear,
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.5),
                                            Color.white.opacity(0.3),
                                            Color.clear
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 120, height: geometry.size.height + 40)
                                .rotationEffect(.degrees(15))
                                .offset(x: shimmerOffset)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation(.spring(response: 1.0, dampingFraction: 0.9)) {
                                            shimmerOffset = geometry.size.width + 100
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        viewModel.lastCreatedNoteId = nil
                                    }
                                }
                        }
                    }
                }
                .clipShape(Rectangle())
            )
            .contextMenu {
                Button(action: {
                    HapticsManager.shared.impact(.soft)
                    UIPasteboard.general.string = note.content
                }) {
                    Label("Copy Text", systemImage: "doc.on.doc")
                }
                
                Button(role: .destructive, action: {
                    HapticsManager.shared.impact(.soft)
                    viewModel.deleteNote(note)
                }) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

struct EmptyPositivityView: View {
    let selectedFont: FontOption
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 50))
                .foregroundColor(accentColor.opacity(0.5))
            
            Text("Start Your Positivity Journey")
                .appFont(selectedFont)
                .font(.title2)
                .foregroundColor(.primary)
            
            Text("Tap the + button to add your first positive note")
                .appFont(selectedFont)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}