import Foundation
import CoreData

@objc(CDUser)
public class CDUser: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var avatarName: String?
    @NSManaged public var theme: String
    @NSManaged public var remindersEnabled: Bool
    @NSManaged public var reminders: Data?
    @NSManaged public var trackers: NSSet?
    @NSManaged public var achievements: NSSet?
}


extension CDUser {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDUser> {
        return NSFetchRequest<CDUser>(entityName: "User")
    }
    
    var trackersArray: [CDTracker] {
        let set = trackers as? Set<CDTracker> ?? []
        return set.sorted { $0.name < $1.name }
    }
    
    var achievementsArray: [CDAchievement] {
        let set = achievements as? Set<CDAchievement> ?? []
        return set.sorted { $0.dateAchieved > $1.dateAchieved }
    }
}

@objc(CDTracker)
public class CDTracker: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var iconName: String
    @NSManaged public var targetDays: Int16
    @NSManaged public var createdDate: Date
    @NSManaged public var user: CDUser?
    @NSManaged public var entries: NSSet?
}

extension CDTracker {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDTracker> {
        return NSFetchRequest<CDTracker>(entityName: "Tracker")
    }
    
    var entriesArray: [CDTrackingEntry] {
        let set = entries as? Set<CDTrackingEntry> ?? []
        return set.sorted { $0.date < $1.date }
    }
}

@objc(CDTrackingEntry)
public class CDTrackingEntry: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var isCompleted: Bool
    @NSManaged public var tracker: CDTracker?
}

extension CDTrackingEntry {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDTrackingEntry> {
        return NSFetchRequest<CDTrackingEntry>(entityName: "TrackingEntry")
    }
}

@objc(CDAchievement)
public class CDAchievement: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var achievementDescription: String
    @NSManaged public var iconName: String
    @NSManaged public var dateAchieved: Date
    @NSManaged public var user: CDUser?
}

extension CDAchievement {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDAchievement> {
        return NSFetchRequest<CDAchievement>(entityName: "Achievement")
    }
}

@objc(CDReward)
public class CDReward: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var rewardDescription: String
    @NSManaged public var iconName: String
    @NSManaged public var streakDays: Int16
    @NSManaged public var user: CDUser?
}

extension CDReward {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDReward> {
        return NSFetchRequest<CDReward>(entityName: "Reward")
    }
}
