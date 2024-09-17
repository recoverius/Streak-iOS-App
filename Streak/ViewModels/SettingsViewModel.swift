import Foundation
import Combine
import UserNotifications

class SettingsViewModel: ObservableObject {
    @Published var userName: String
    @Published var remindersEnabled: Bool
    @Published var reminders: [Reminder]
    @Published var selectedTheme: AppTheme
    @Published var notificationStatus: UNAuthorizationStatus = .notDetermined
    
    private let coreDataManager = CoreDataManager.shared
    private let notificationManager = NotificationManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let user = coreDataManager.fetchUser() ?? coreDataManager.createUser(name: "New User", avatarName: nil)
        self.userName = user.name
        self.remindersEnabled = user.settings.notificationPreferences.remindersEnabled
        self.reminders = user.settings.notificationPreferences.reminders
        self.selectedTheme = user.settings.theme
        
        checkNotificationStatus()
    }
    
    func checkNotificationStatus() {
        notificationManager.checkPermissionStatus { status in
            DispatchQueue.main.async {
                self.notificationStatus = status
            }
        }
    }
    
    func requestNotificationPermission() {
        notificationManager.requestPermission { granted in
            self.checkNotificationStatus()
            if granted {
                self.scheduleNotifications()
            }
        }
    }
    
    func scheduleNotifications() {
        if remindersEnabled {
            notificationManager.cancelAllNotifications()
            for reminder in reminders {
                notificationManager.scheduleNotification(at: reminder.time, customText: reminder.customText)
            }
        } else {
            notificationManager.cancelAllNotifications()
        }
    }
    
    func saveSettings() {
        var user = coreDataManager.fetchUser() ?? coreDataManager.createUser(name: "New User", avatarName: nil)
        user.name = userName
        user.settings.notificationPreferences.remindersEnabled = remindersEnabled
        user.settings.notificationPreferences.reminders = reminders
        user.settings.theme = selectedTheme
        
        coreDataManager.updateUser(user)
        scheduleNotifications()
    }
    
    func resetAllData() {
        coreDataManager.resetAllData()
        notificationManager.cancelAllNotifications()
        
        // Reset local state
        userName = "New User"
        remindersEnabled = false
        reminders = []
        selectedTheme = .system
    }
}
