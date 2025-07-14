//
//  PositiveNoteViewModel.swift
//  Kipped
//
//  Created by Ben Robinson on 28/06/2025.
//

import Foundation
import UserNotifications

class PositiveNoteViewModel: ObservableObject {
    @Published var notes: [PositiveNote] = [] {
        didSet {
            saveNotes()
        }
    }
    @Published var lastCreatedNoteId: UUID?
    
    private let notesKey = "positive_notes_key"
    private let dailyNotificationId = "daily_positivity_reminder"
    private let onboardingDateKey = "user_onboarding_date"
    
    init() {
        loadNotes()
        cleanupEmptyNotes()
        setupOnboardingDate()
        setupDailyNotification()
    }
    
    // MARK: - Onboarding Date Management
    
    private func setupOnboardingDate() {
        if UserDefaults.standard.object(forKey: onboardingDateKey) == nil {
            // First time user - set onboarding date to today
            UserDefaults.standard.set(Date(), forKey: onboardingDateKey)
        }
    }
    
    var onboardingDate: Date {
        UserDefaults.standard.object(forKey: onboardingDateKey) as? Date ?? Date()
    }
    
    func daysSinceOnboarding() -> Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: onboardingDate, to: Date()).day ?? 0
        return max(0, days)
    }
    
    func dateForDay(_ day: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: day, to: onboardingDate) ?? onboardingDate
    }
    
    // MARK: - Note Management
    
    func addNote(content: String, for date: Date = Date()) {
        // Normalize the date to start of day
        let normalizedDate = Calendar.current.startOfDay(for: date)
        
        // Check if note already exists for this date
        if let existingIndex = notes.firstIndex(where: { 
            Calendar.current.isDate($0.date, inSameDayAs: normalizedDate) 
        }) {
            // Update existing note
            notes[existingIndex].content = content
            lastCreatedNoteId = notes[existingIndex].id
        } else {
            // Create new note
            let newNote = PositiveNote(content: content, date: normalizedDate)
            notes.append(newNote)
            lastCreatedNoteId = newNote.id
        }
    }
    
    func updateNote(_ note: PositiveNote, newContent: String) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].content = newContent
        }
    }
    
    func updateNote(_ note: PositiveNote, newContent: String, newDate: Date) {
        // Normalize the new date
        let normalizedNewDate = Calendar.current.startOfDay(for: newDate)
        
        // Find and remove the old note
        guard let oldIndex = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes.remove(at: oldIndex)
        
        // Check if a note already exists for the new date
        if let existingIndex = notes.firstIndex(where: { 
            Calendar.current.isDate($0.date, inSameDayAs: normalizedNewDate) 
        }) {
            // Replace the existing note for that date
            notes[existingIndex].content = newContent
            notes[existingIndex].date = normalizedNewDate
            lastCreatedNoteId = notes[existingIndex].id
        } else {
            // Create a new note with the updated date
            let updatedNote = PositiveNote(
                id: note.id,
                content: newContent,
                date: normalizedNewDate,
                createdAt: note.createdAt
            )
            notes.append(updatedNote)
            lastCreatedNoteId = updatedNote.id
        }
    }
    
    func deleteNote(_ note: PositiveNote) {
        notes.removeAll { $0.id == note.id }
    }
    
    func getNoteForDate(_ date: Date) -> PositiveNote? {
        notes.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func hasNoteForDate(_ date: Date) -> Bool {
        notes.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    // MARK: - View Helpers
    
    var sortedNotes: [PositiveNote] {
        notes.sorted { $0.date > $1.date }
    }
    
    var notesGroupedByMonth: [Date: [PositiveNote]] {
        Dictionary(grouping: notes) { note in
            Calendar.current.dateInterval(of: .month, for: note.date)?.start ?? note.date
        }
    }
    
    var currentYearProgress: (completed: Int, total: Int) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let endOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!
        
        let daysInYear = calendar.dateComponents([.day], from: startOfYear, to: endOfYear).day! + 1
        let completedDays = notes.filter { 
            calendar.component(.year, from: $0.date) == year 
        }.count
        
        return (completed: completedDays, total: daysInYear)
    }
    
    var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        while hasNoteForDate(currentDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
        }
        
        return streak
    }
    
    // MARK: - Persistence
    
    private func cleanupEmptyNotes() {
        let originalCount = notes.count
        notes = notes.filter { !$0.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        if notes.count < originalCount {
            print("Cleaned up \(originalCount - notes.count) empty notes")
            saveNotes()
        }
    }
    
    private func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(data, forKey: notesKey)
            
            // Update filled days for widget
            updateFilledDaysForWidget()
        } catch {
            print("Failed to save notes: \(error)")
        }
    }
    
    private func updateFilledDaysForWidget() {
        // Group notes by month and year
        var filledDaysByMonth: [String: [Int]] = [:]
        let calendar = Calendar.current
        
        for note in notes {
            let year = calendar.component(.year, from: note.date)
            let month = calendar.component(.month, from: note.date)
            let day = calendar.component(.day, from: note.date)
            
            let key = "filledDays_\(year)_\(month)"
            if filledDaysByMonth[key] == nil {
                filledDaysByMonth[key] = []
            }
            filledDaysByMonth[key]?.append(day)
        }
        
        // Save to shared UserDefaults
        if let sharedDefaults = UserDefaults(suiteName: "group.com.yourcompany.kipped") {
            // Clear old data first
            let allKeys = sharedDefaults.dictionaryRepresentation().keys.filter { $0.starts(with: "filledDays_") }
            for key in allKeys {
                sharedDefaults.removeObject(forKey: key)
            }
            
            // Save new data
            for (key, days) in filledDaysByMonth {
                sharedDefaults.set(Array(Set(days)), forKey: key)
            }
        }
    }
    
    private func loadNotes() {
        guard let data = UserDefaults.standard.data(forKey: notesKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([PositiveNote].self, from: data)
            notes = decoded
        } catch {
            print("Failed to load notes: \(error)")
        }
    }
    
    // MARK: - Notifications
    
    private func setupDailyNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dailyNotificationId])
        
        let content = UNMutableNotificationContent()
        content.title = "Time for Positivity! ✨"
        content.body = "What's something good that happened today?"
        content.sound = .default
        
        // Set daily trigger at 8 PM
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: dailyNotificationId, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily notification: \(error)")
            }
        }
    }
    
    func updateNotificationTime(hour: Int, minute: Int) {
        setupDailyNotification() // For now, using default time
        // TODO: Implement custom time setting
    }
}