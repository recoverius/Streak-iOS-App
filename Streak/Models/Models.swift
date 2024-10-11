import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    var avatarName: String?
    var settings: UserSettings
    var achievements: [Achievement]
    var trackers: [Tracker]
//    var friends: [Friend]
    
    init(cdUser: CDUser) {
        self.id = cdUser.id
        self.name = cdUser.name
        self.avatarName = cdUser.avatarName
        self.settings = UserSettings(cdUser: cdUser)
        self.achievements = cdUser.achievementsArray.map { Achievement(cdAchievement: $0) }
        self.trackers = cdUser.trackersArray.map { Tracker(cdTracker: $0) }
//        self.friends = cdUser.friendsArray.map { Friend(cdFriend: $0) }
    }
}

struct UserSettings: Codable {
    var notificationPreferences: NotificationPreferences
    var theme: AppTheme
    
    init(cdUser: CDUser) {
        self.notificationPreferences = NotificationPreferences(cdUser: cdUser)
        self.theme = AppTheme(rawValue: cdUser.theme) ?? .system
    }
}

struct NotificationPreferences: Codable {
    var remindersEnabled: Bool
    var reminders: [Reminder]
    
    init(cdUser: CDUser) {
        self.remindersEnabled = cdUser.remindersEnabled
        
        if let remindersData = cdUser.reminders,
           let decodedReminders = try? JSONDecoder().decode([Reminder].self, from: remindersData) {
            self.reminders = decodedReminders
        } else {
            self.reminders = []
        }
    }
}

struct Reminder: Codable, Identifiable, Equatable {
    let id: UUID
    var time: Date
    var customText: String?
}

struct Tracker: Identifiable, Codable {
       let id: UUID
       var name: String
       var iconName: String
       var colorName: String
       var target: HabitTarget
       var createdDate: Date
       var entries: [TrackingEntry]
       var startDate: Date

       init(cdTracker: CDTracker) {
           self.id = cdTracker.id
           self.name = cdTracker.name
           self.iconName = cdTracker.iconName
           self.colorName = cdTracker.colorName.isEmpty ? "pastelBlue" : cdTracker.colorName
           self.target = HabitTarget(rawValue: Int(cdTracker.targetDays)) ?? .daily
           self.createdDate = cdTracker.createdDate

           // Safely handle the optional startDate
           if let startDate = cdTracker.startDate {
               let defaultDate = Date(timeIntervalSinceReferenceDate: 0) // January 1, 2001
               if startDate == defaultDate {
                   self.startDate = cdTracker.createdDate
               } else {
                   self.startDate = startDate
               }
           } else {
               // If startDate is nil, use createdDate
               self.startDate = cdTracker.createdDate
           }

           self.entries = cdTracker.entriesArray.map { TrackingEntry(cdEntry: $0) }
       }
   }

struct TrackingEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    var isCompleted: Bool
    
    init(cdEntry: CDTrackingEntry) {
        self.id = cdEntry.id
        self.date = cdEntry.date
        self.isCompleted = cdEntry.isCompleted
    }
}

struct Achievement: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var iconName: String
    var dateAchieved: Date
    
    init(cdAchievement: CDAchievement) {
        self.id = cdAchievement.id
        self.title = cdAchievement.title
        self.description = cdAchievement.achievementDescription
        self.iconName = cdAchievement.iconName
        self.dateAchieved = cdAchievement.dateAchieved
    }
}

struct Reward: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var iconName: String
    var criteria: RewardCriteria
    
    init(cdReward: CDReward) {
        self.id = cdReward.id
        self.title = cdReward.title
        self.description = cdReward.rewardDescription
        self.iconName = cdReward.iconName
        self.criteria = RewardCriteria(streakDays: Int(cdReward.streakDays))
    }
}

struct RewardCriteria: Codable {
    var streakDays: Int
}

enum HabitTarget: Codable, Hashable {
    case daily
    case weekly
    case custom(days: Int)
    
    init?(rawValue: Int) {
        switch rawValue {
        case 1: self = .daily
        case 7: self = .weekly
        case let days where days > 0: self = .custom(days: days)
        default: return nil
        }
    }
    
    var rawValue: Int {
        switch self {
        case .daily: return 1
        case .weekly: return 7
        case .custom(let days): return days
        }
    }
}

enum AppTheme: String, Codable {
    case light
    case dark
    case system
}
