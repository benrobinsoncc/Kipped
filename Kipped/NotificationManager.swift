import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private let notificationIdentifier = "daily-positivity-reminder"
    private let notificationTimeKey = "notification_time"
    static let notificationCategoryIdentifier = "daily-positivity-category"
    static let notificationTappedNotification = Notification.Name("NotificationTapped")
    
    private override init() {
        super.init()
        setupNotificationCategories()
        UNUserNotificationCenter.current().delegate = self
    }
    
    private func setupNotificationCategories() {
        let category = UNNotificationCategory(
            identifier: NotificationManager.notificationCategoryIdentifier,
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    // MARK: - Public Methods
    
    func requestNotificationPermissions(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification permission error: \(error)")
                    completion(false)
                } else {
                    completion(granted)
                }
            }
        }
    }
    
    func scheduleDailyNotification(at time: Date) {
        // Cancel existing notifications
        cancelDailyNotification()
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Daily Reflection"
        content.body = "What made you smile today?"
        content.sound = .default
        content.categoryIdentifier = NotificationManager.notificationCategoryIdentifier
        
        // Extract hour and minute from the selected time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        // Create daily trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Daily notification scheduled for \(components.hour ?? 0):\(String(format: "%02d", components.minute ?? 0))")
            }
        }
        
        // Save the notification time
        saveNotificationTime(time)
    }
    
    func cancelDailyNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
    }
    
    func checkNotificationStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    // MARK: - Persistence
    
    func saveNotificationTime(_ time: Date) {
        UserDefaults.standard.set(time, forKey: notificationTimeKey)
    }
    
    func loadNotificationTime() -> Date {
        if let savedTime = UserDefaults.standard.object(forKey: notificationTimeKey) as? Date {
            return savedTime
        }
        
        // Default to 8 PM
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = 20
        components.minute = 0
        return calendar.date(from: components) ?? Date()
    }
    
    func isNotificationScheduled() -> Bool {
        return UserDefaults.standard.object(forKey: notificationTimeKey) != nil
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                              willPresent notification: UNNotification, 
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                              didReceive response: UNNotificationResponse, 
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        // Check if this is our daily positivity notification
        if response.notification.request.content.categoryIdentifier == NotificationManager.notificationCategoryIdentifier {
            // Post notification to open create modal
            NotificationCenter.default.post(name: NotificationManager.notificationTappedNotification, object: nil)
        }
        completionHandler()
    }
}