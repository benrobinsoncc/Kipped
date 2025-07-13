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
    
    @State private var content: String
    @State private var selectedDate: Date = Date()
    @State private var tempSelectedDate: Date = Date()
    @State private var showingDatePicker: Bool = false
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextEditorFocused: Bool
    
    init(viewModel: PositiveNoteViewModel, noteToEdit: PositiveNote? = nil, dateToEdit: Date? = nil, accentColor: Binding<Color>, selectedFont: Binding<FontOption>) {
        self.viewModel = viewModel
        self.noteToEdit = noteToEdit
        self.dateToEdit = dateToEdit
        self._accentColor = accentColor
        self._selectedFont = selectedFont
        
        // Initialize content based on whether we're editing or creating
        if let note = noteToEdit {
            self._content = State(initialValue: note.content)
        } else {
            self._content = State(initialValue: "")
        }
    }
    
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
            ZStack {
                // Main content
                ScrollView {
                    VStack(spacing: 24) {
                        // Content input
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $content)
                                .appFont(selectedFont)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                                .frame(minHeight: 120)
                                .focused($isTextEditorFocused)
                            
                            // Placeholder text
                            if content.isEmpty {
                                Text("What made you happy today?")
                                    .appFont(selectedFont)
                                    .foregroundColor(.secondary.opacity(0.6))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 8)
                                    .allowsHitTesting(false)
                            }
                        }
                        
                        
                        // Spacer to prevent content from being hidden under save button
                        Color.clear
                            .frame(height: 80)
                    }
                    .padding()
                }
                
                // Fixed save button overlay at bottom
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        SkeuomorphicSaveButton(
                            accentColor: accentColor,
                            isEnabled: !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                            action: saveNote
                        )
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
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
            // Focus the text editor after a slight delay to ensure the view is loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextEditorFocused = true
            }
        }
    }
    
    private func setupInitialValues() {
        if let note = noteToEdit {
            selectedDate = Calendar.current.startOfDay(for: note.date)
        } else if let date = dateToEdit {
            selectedDate = Calendar.current.startOfDay(for: date)
        } else {
            selectedDate = Calendar.current.startOfDay(for: Date())
        }
    }
    
    private func saveNote() {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else { return }
        
        if let note = noteToEdit {
            // Check if the date has changed
            if !Calendar.current.isDate(note.date, inSameDayAs: selectedDate) {
                // Date has changed, use the method that handles date updates
                viewModel.updateNote(note, newContent: trimmedContent, newDate: selectedDate)
            } else {
                // Only content has changed
                viewModel.updateNote(note, newContent: trimmedContent)
            }
        } else {
            viewModel.addNote(content: trimmedContent, for: selectedDate)
        }
        
        HapticsManager.shared.impact(.medium)
        dismiss()
    }
}