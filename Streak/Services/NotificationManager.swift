//
//  NotificationManager.swift
//  Streak
//
//  Created by Ilya Golubev on 17/09/2024.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    let notificationTexts = [
        "Time to keep your streak alive! Don't break the chain.",
        "Your habits are waiting for you. Let's make progress!",
        "Consistency is key. Check in with your habits now.",
        "Your future self will thank you for sticking to your habits today.",
        "Small steps lead to big changes. Time to check off your habits!",
        "Habit time! Let's make today count.",
        "Your goals are calling. Answer with action!",
        "Momentum builds success. Keep your habits going strong.",
        "It's habit o'clock! Time to make yourself proud.",
        "Your streak is on the line. Let's keep it going!"
    ]
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    func scheduleNotification(at date: Date, customText: String? = nil) {
            let content = UNMutableNotificationContent()
            content.title = "Streak Reminder"
            content.body = customText ?? notificationTexts.randomElement() ?? "Time to check your habits!"
            content.sound = .default
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
