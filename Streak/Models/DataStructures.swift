import Foundation
import SwiftUI

struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    var avatarName: String? // Using String to represent avatar image name
    var settings: UserSettings
    var achievements: [Achievement]
    
    init(id: UUID = UUID(), name: String, avatarName: String? = nil, settings: UserSettings = UserSettings(), achievements: [Achievement] = []) {
        self.id = id
        self.name = name
        self.avatarName = avatarName
        self.settings = settings
        self.achievements = achievements
    }
}

struct Tracker: Identifiable, Codable {
    let id: UUID
    var name: String
    var iconName: String // Using String to represent icon name
    var target: HabitTarget
    var createdDate: Date
    var trackingEntries: [TrackingEntry]
    
    init(id: UUID = UUID(), name: String, iconName: String, target: HabitTarget, createdDate: Date = Date(), trackingEntries: [TrackingEntry] = []) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.target = target
        self.createdDate = createdDate
        self.trackingEntries = trackingEntries
    }
}

struct TrackingEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    var isCompleted: Bool
    
    init(id: UUID = UUID(), date: Date, isCompleted: Bool = false) {
        self.id = id
        self.date = date
        self.isCompleted = isCompleted
    }
}

struct Achievement: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var iconName: String // Using String to represent icon name
    var dateAchieved: Date
    
    init(id: UUID = UUID(), title: String, description: String, iconName: String, dateAchieved: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.dateAchieved = dateAchieved
    }
}

struct UserSettings: Codable {
    var notificationPreferences: NotificationPreferences = NotificationPreferences()
    var theme: AppTheme = .light
    var linkedDevices: [Device] = []
}

enum HabitTarget: Codable, Hashable {
    case daily
    case weekly
    case custom(days: Int)
}

struct NotificationPreferences: Codable {
    var remindersEnabled: Bool = false
    var reminderTimes: [Date] = []
}

enum AppTheme: String, Codable {
    case light
    case dark
    case system
}

struct Device: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: DeviceType
}

enum DeviceType: String, Codable {
    case iPhone
    case AppleWatch
    case iPad
    case Mac
}
