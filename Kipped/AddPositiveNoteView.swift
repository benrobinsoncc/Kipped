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
    @Environment(\.dismiss) private var dismiss
    
    private var isEditing: Bool {
        noteToEdit != nil
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(selectedDate) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(selectedDate) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .full
            return formatter.string(from: selectedDate)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Date selector
                VStack(spacing: 8) {
                    Text("Date")
                        .appFont(selectedFont)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    DatePicker(
                        "",
                        selection: $selectedDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .tint(accentColor)
                    .disabled(isEditing) // Can't change date when editing
                }
                
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
                
                // Save button
                Button(action: saveNote) {
                    Text(isEditing ? "Update" : "Save")
                        .appFont(selectedFont)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(accentColor)
                        .cornerRadius(12)
                }
                .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
            }
            .padding()
            .navigationTitle(isEditing ? "Edit Note" : "Add Positive Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .appFont(selectedFont)
                }
            }
        }
        .onAppear {
            setupInitialValues()
        }
    }
    
    private func setupInitialValues() {
        if let note = noteToEdit {
            content = note.content
            selectedDate = note.date
        } else if let date = dateToEdit {
            selectedDate = date
            // Pre-fill if there's already a note for this date
            if let existingNote = viewModel.getNoteForDate(date) {
                content = existingNote.content
            }
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