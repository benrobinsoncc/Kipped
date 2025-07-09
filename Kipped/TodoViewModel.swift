//
//  TodoViewModel.swift
//  Kipped
//
//  Created by Ben Robinson on 28/06/2025.
//

import Foundation
import UserNotifications

class TodoViewModel: ObservableObject {
    @Published var todos: [Todo] = [] {
        didSet {
            saveTodos()
        }
    }
    @Published var lastCreatedTodoId: UUID?
    
    private let todosKey = "todos_key"

    init() {
        loadTodos()
    }
    
    func addTodo(title: String, reminderDate: Date? = nil) {
        let newTodo = Todo(title: title, reminderDate: reminderDate)
        todos.append(newTodo)
        lastCreatedTodoId = newTodo.id
        scheduleNotification(for: newTodo)
    }
    
    func toggleTodo(_ todo: Todo) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isCompleted.toggle()
        }
    }
    
    func deleteTodo(_ todo: Todo) {
        todos.removeAll { $0.id == todo.id }
        removeNotification(for: todo)
    }
    
    func updateTodo(_ todo: Todo, newTitle: String, newReminderDate: Date?) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].title = newTitle
            todos[index].reminderDate = newReminderDate
            scheduleNotification(for: todos[index])
        }
    }
    
    private func scheduleNotification(for todo: Todo) {
        guard let reminderDate = todo.reminderDate else { return }
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = todo.title
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate), repeats: false)
        let request = UNNotificationRequest(identifier: todo.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    private func removeNotification(for todo: Todo) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [todo.id.uuidString])
    }
    
    private func saveTodos() {
        do {
            let data = try JSONEncoder().encode(todos)
            UserDefaults.standard.set(data, forKey: todosKey)
        } catch {
            print("Failed to save todos: \(error)")
        }
    }
    
    private func loadTodos() {
        guard let data = UserDefaults.standard.data(forKey: todosKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([Todo].self, from: data)
            todos = decoded
        } catch {
            print("Failed to load todos: \(error)")
        }
    }
    
    func archiveTodo(_ todo: Todo) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isArchived = true
            removeNotification(for: todo)
        }
    }
    
    func unarchiveTodo(_ todo: Todo) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isArchived = false
        }
    }
    
    var activeTodos: [Todo] {
        todos.filter { !$0.isArchived }
    }
    
    var archivedTodos: [Todo] {
        todos.filter { $0.isArchived }
    }
} 