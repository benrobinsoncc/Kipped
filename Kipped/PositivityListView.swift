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
                    // Grouped by month (default behavior)
                    ForEach(sortedMonthGroups, id: \.key) { month, notes in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(monthYearString(from: month))
                                .appFont(selectedFont)
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                                .padding(.top, 16)
                            
                            ForEach(notes.sorted(by: { $0.date > $1.date })) { note in
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
                                    isNewlyCreated: viewModel.lastCreatedNoteId == note.id
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Bottom spacing to allow content to scroll into fade zone
                    Color.clear.frame(height: 200)
                }
            }
        }
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
    
    @State private var isPressed = false
    @State private var shimmerOffset: CGFloat = -100
    
    private var dateString: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(note.date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(note.date) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: note.date)
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(dateString)
                        .appFont(selectedFont)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(accentColor)
                        .font(.caption)
                }
                
                Text(note.content)
                    .appFont(selectedFont)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
            .padding()
            .background(Color.tintedSecondaryBackground(accentColor: accentColor, isEnabled: tintedBackgrounds, colorScheme: colorScheme))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
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
                        RoundedRectangle(cornerRadius: 16)
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
            .clipShape(RoundedRectangle(cornerRadius: 16))
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