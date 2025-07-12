//
//  AddPositiveNoteView.swift
//  Kipped
//
//  Created by Ben Robinson on 28/06/2025.
//

import SwiftUI

struct AddPositiveNoteView: View {
    @ObservedObject var viewModel: PositiveNoteViewModel
    var noteToEdit: PositiveNote?
    var dateToEdit: Date?
    @Binding var accentColor: Color
    @Binding var selectedFont: FontOption
    
    @State private var content: String = ""
    @State private var selectedDate: Date = Date()
    @State private var tempSelectedDate: Date = Date()
    @State private var showingDatePicker: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    private var dateOptions: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var dates: [Date] = []
        
        // Generate dates for the past 365 days
        for i in 0...365 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                dates.append(date)
            }
        }
        return dates
    }
    
    private func formatDateForPicker(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let formatter = DateFormatter()
        
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "MMM d"
            return "Today, \(formatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            formatter.dateFormat = "MMM d"
            return "Yesterday, \(formatter.string(from: date))"
        } else {
            // Check if it's this week
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.end ?? now
            
            if date >= startOfWeek && date < endOfWeek {
                // Earlier this week
                formatter.dateFormat = "EEE, MMM d"
                return formatter.string(from: date)
            } else {
                // Check if it's last week
                let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: startOfWeek) ?? now
                if date >= lastWeekStart && date < startOfWeek {
                    // Last week
                    formatter.dateFormat = "EEE, MMM d"
                    let fullDate = formatter.string(from: date)
                    let components = fullDate.split(separator: ",")
                    if let dayPart = components.first {
                        return "Last \(dayPart), \(components.dropFirst().joined(separator: ","))"
                    }
                    return fullDate
                } else {
                    // Earlier than that
                    formatter.dateFormat = "EEE, MMM d"
                    return formatter.string(from: date)
                }
            }
        }
    }
    
    private var isEditing: Bool {
        noteToEdit != nil
    }
    
    private var dateString: String {
        let calendar = Calendar.current
        let now = Date()
        let formatter = DateFormatter()
        
        if calendar.isDateInToday(selectedDate) {
            formatter.dateFormat = "MMM d"
            return "Today, \(formatter.string(from: selectedDate))"
        } else if calendar.isDateInYesterday(selectedDate) {
            formatter.dateFormat = "MMM d"
            return "Yesterday, \(formatter.string(from: selectedDate))"
        } else {
            // Check if it's this week
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.end ?? now
            
            if selectedDate >= startOfWeek && selectedDate < endOfWeek {
                // Earlier this week
                formatter.dateFormat = "EEE, MMM d"
                return formatter.string(from: selectedDate)
            } else {
                // Check if it's last week
                let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: startOfWeek) ?? now
                if selectedDate >= lastWeekStart && selectedDate < startOfWeek {
                    // Last week
                    formatter.dateFormat = "EEE, MMM d"
                    let fullDate = formatter.string(from: selectedDate)
                    let components = fullDate.split(separator: ",")
                    if let dayPart = components.first {
                        return "Last \(dayPart), \(components.dropFirst().joined(separator: ","))"
                    }
                    return fullDate
                } else {
                    // Earlier than that
                    formatter.dateFormat = "EEE, MMM d"
                    return formatter.string(from: selectedDate)
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Content input
                VStack(spacing: 8) {
                    Text("What's something positive that happened?")
                        .appFont(selectedFont)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextEditor(text: $content)
                        .appFont(selectedFont)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .frame(minHeight: 120)
                }
                
                // Inspiration prompts
                if content.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Need inspiration? Try these:")
                            .appFont(selectedFont)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(inspirationPrompts, id: \.self) { prompt in
                                Button(action: {
                                    content = prompt
                                    HapticsManager.shared.impact(.soft)
                                }) {
                                    Text(prompt)
                                        .appFont(selectedFont)
                                        .font(.caption)
                                        .foregroundColor(accentColor)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(accentColor.opacity(0.1))
                                        .cornerRadius(16)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                
                Spacer()
                
                // Save button with skeuomorphic style
                HStack {
                    Spacer()
                    SkeuomorphicSaveButton(
                        accentColor: accentColor,
                        isEnabled: !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                        action: saveNote
                    )
                    Spacer()
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if isEditing {
                        Text("Edit Note")
                            .appFont(selectedFont)
                            .font(.headline)
                            .fontWeight(.semibold)
                    } else {
                        Button(action: {
                            tempSelectedDate = Calendar.current.startOfDay(for: selectedDate)
                            showingDatePicker = true
                        }) {
                            HStack(spacing: 4) {
                                Text(dateString)
                                    .appFont(selectedFont)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            NavigationView {
                VStack {
                    HStack(spacing: 0) {
                        // Month picker
                        Picker("Month", selection: Binding(
                            get: {
                                Calendar.current.component(.month, from: tempSelectedDate) - 1
                            },
                            set: { newMonth in
                                var components = Calendar.current.dateComponents([.year, .month, .day], from: tempSelectedDate)
                                components.month = newMonth + 1
                                
                                // Adjust day if it exceeds the new month's days
                                if let range = Calendar.current.range(of: .day, in: .month, for: Calendar.current.date(from: components) ?? Date()),
                                   let currentDay = components.day,
                                   currentDay > range.count {
                                    components.day = range.count
                                }
                                
                                if let newDate = Calendar.current.date(from: components) {
                                    tempSelectedDate = newDate
                                }
                            }
                        )) {
                            ForEach(0..<12, id: \.self) { monthIndex in
                                Text(Calendar.current.monthSymbols[monthIndex])
                                    .tag(monthIndex)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 150)
                        
                        // Day picker
                        Picker("Day", selection: Binding(
                            get: {
                                Calendar.current.component(.day, from: tempSelectedDate)
                            },
                            set: { newDay in
                                var components = Calendar.current.dateComponents([.year, .month, .day], from: tempSelectedDate)
                                components.day = newDay
                                if let newDate = Calendar.current.date(from: components) {
                                    tempSelectedDate = newDate
                                }
                            }
                        )) {
                            let daysInMonth = Calendar.current.range(of: .day, in: .month, for: tempSelectedDate)?.count ?? 31
                            ForEach(1...daysInMonth, id: \.self) { day in
                                Text("\(day)")
                                    .tag(day)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                    }
                    .frame(height: 200)
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Select date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            selectedDate = tempSelectedDate
                            showingDatePicker = false
                        }
                        .appFont(selectedFont)
                    }
                }
            }
            .presentationDetents([.fraction(0.3)])
        }
        .onAppear {
            setupInitialValues()
        }
    }
    
    private func setupInitialValues() {
        if let note = noteToEdit {
            content = note.content
            selectedDate = Calendar.current.startOfDay(for: note.date)
        } else if let date = dateToEdit {
            selectedDate = Calendar.current.startOfDay(for: date)
            // Pre-fill if there's already a note for this date
            if let existingNote = viewModel.getNoteForDate(date) {
                content = existingNote.content
            }
        } else {
            selectedDate = Calendar.current.startOfDay(for: Date())
        }
    }
    
    private func saveNote() {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else { return }
        
        if let note = noteToEdit {
            viewModel.updateNote(note, newContent: trimmedContent)
        } else {
            viewModel.addNote(content: trimmedContent, for: selectedDate)
        }
        
        HapticsManager.shared.impact(.medium)
        dismiss()
    }
    
    private var inspirationPrompts: [String] {
        [
            "Someone made me smile",
            "I felt grateful for...",
            "I accomplished something",
            "I learned something new",
            "I helped someone",
            "Beautiful weather today",
            "Good food/coffee",
            "Made progress on a goal"
        ]
    }
}