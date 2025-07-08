//
//  AddTodoView.swift
//  Kipped
//
//  Created by Ben Robinson on 28/06/2025.
//

import SwiftUI

struct AddTodoView: View {
    @ObservedObject var todoViewModel: TodoViewModel
    var todoToEdit: Todo?
    @Binding var colorScheme: ColorScheme
    @Binding var accentColor: Color
    @Binding var selectedFont: FontOption
    var isArchivedMode: Bool = false
    var onUnarchive: (() -> Void)? = nil
    
    @State private var title: String = ""
    @State private var reminderDate: Date = Date()
    @State private var hasReminder: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter note title", text: $title)
                    .appFont(selectedFont)
                    .font(.title2)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                
                Toggle("Set Reminder", isOn: $hasReminder)
                    .appFont(selectedFont)
                    .tint(accentColor)
                
                if hasReminder {
                    DatePicker("Reminder Date", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                        .appFont(selectedFont)
                        .tint(accentColor)
                }
                
                Spacer()
                
                if isArchivedMode {
                    Button("Unarchive") {
                        onUnarchive?()
                        dismiss()
                    }
                    .appFont(selectedFont)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(accentColor)
                    .cornerRadius(12)
                }
            }
            .padding()
            .navigationTitle(todoToEdit != nil ? "Edit Note" : "New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .appFont(selectedFont)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let todoToEdit = todoToEdit {
                            todoViewModel.updateTodo(todoToEdit, newTitle: title, newReminderDate: hasReminder ? reminderDate : nil)
                        } else {
                            todoViewModel.addTodo(title: title, reminderDate: hasReminder ? reminderDate : nil)
                        }
                        dismiss()
                    }
                    .appFont(selectedFont)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            if let todoToEdit = todoToEdit {
                title = todoToEdit.title
                if let reminder = todoToEdit.reminderDate {
                    hasReminder = true
                    reminderDate = reminder
                }
            }
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview {
    AddTodoView(todoViewModel: TodoViewModel(), colorScheme: .constant(.dark), accentColor: .constant(.blue), selectedFont: .constant(.system))
}