import CoreData


class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {
        _ = persistentContainer.viewContext
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HabitTracker")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }


    func deleteTracker(_ tracker: Tracker) {
        guard let cdTracker = fetchCDTracker(with: tracker.id) else {
            print("Failed to fetch CDTracker for deletion")
            return
        }
        
        // Delete associated tracking entries
        let fetchRequest: NSFetchRequest<CDTrackingEntry> = CDTrackingEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker == %@", cdTracker)
        
        do {
            let entries = try viewContext.fetch(fetchRequest)
            for entry in entries {
                viewContext.delete(entry)
            }
        } catch {
            print("Error fetching tracking entries for deletion: \(error)")
        }
        
        // Delete the tracker
        viewContext.delete(cdTracker)
        
        // Save changes
        saveContext()
    }
    
    func updateUser(_ user: User) {
            guard let cdUser = fetchCDUser(with: user.id) else {
                fatalError("Failed to fetch CDUser")
            }
            cdUser.name = user.name
            cdUser.avatarName = user.avatarName
            cdUser.theme = user.settings.theme.rawValue
            cdUser.remindersEnabled = user.settings.notificationPreferences.remindersEnabled
            
            // Store reminders as Data
            cdUser.reminders = try? JSONEncoder().encode(user.settings.notificationPreferences.reminders)
            
            saveContext()
        }

        func createUser(name: String, avatarName: String?) -> User {
            let cdUser = CDUser(context: viewContext)
            cdUser.id = UUID()
            cdUser.name = name
            cdUser.avatarName = avatarName
            cdUser.theme = AppTheme.system.rawValue
            cdUser.remindersEnabled = false
            cdUser.reminders = try? JSONEncoder().encode([Reminder]())
            saveContext()
            return User(cdUser: cdUser)
        }

    func createTracker(name: String, iconName: String, target: HabitTarget, for user: User) -> Tracker {
        guard let cdUser = fetchCDUser(with: user.id) else {
            fatalError("Failed to fetch CDUser")
        }
        let cdTracker = CDTracker(context: viewContext)
        cdTracker.id = UUID()
        cdTracker.name = name
        cdTracker.iconName = iconName
        cdTracker.targetDays = Int16(target.rawValue)
        cdTracker.createdDate = Date()
        cdTracker.user = cdUser
        saveContext()
        return Tracker(cdTracker: cdTracker)
    }
    
    func createTrackingEntry(for tracker: Tracker, date: Date, isCompleted: Bool) -> TrackingEntry {
        guard let cdTracker = fetchCDTracker(with: tracker.id) else {
            fatalError("Failed to fetch CDTracker")
        }
        let cdEntry = CDTrackingEntry(context: viewContext)
        cdEntry.id = UUID()
        cdEntry.date = date
        cdEntry.isCompleted = isCompleted
        cdEntry.tracker = cdTracker
        saveContext()
        return TrackingEntry(cdEntry: cdEntry)
    }
    
    func createAchievement(title: String, description: String, iconName: String, for user: User) -> Achievement {
        guard let cdUser = fetchCDUser(with: user.id) else {
            fatalError("Failed to fetch CDUser")
        }
        let cdAchievement = CDAchievement(context: viewContext)
        cdAchievement.id = UUID()
        cdAchievement.title = title
        cdAchievement.achievementDescription = description
        cdAchievement.iconName = iconName
        cdAchievement.dateAchieved = Date()
        cdAchievement.user = cdUser
        saveContext()
        return Achievement(cdAchievement: cdAchievement)
    }
    
    func fetchUser() -> User? {
        let request: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        do {
            let cdUsers = try viewContext.fetch(request)
            return cdUsers.first.map { User(cdUser: $0) }
        } catch {
            print("Error fetching user: \(error)")
            return nil
        }
    }
    
    func fetchTrackers(for user: User) -> [Tracker] {
        let request: NSFetchRequest<CDTracker> = CDTracker.fetchRequest()
        request.predicate = NSPredicate(format: "user.id == %@", user.id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDTracker.name, ascending: true)]
        do {
            let cdTrackers = try viewContext.fetch(request)
            return cdTrackers.map { Tracker(cdTracker: $0) }
        } catch {
            print("Error fetching trackers: \(error)")
            return []
        }
    }
    func toggleHabitCompletion(for tracker: Tracker, on date: Date) {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let request: NSFetchRequest<CDTrackingEntry> = CDTrackingEntry.fetchRequest()
            request.predicate = NSPredicate(format: "tracker.id == %@ AND date >= %@ AND date < %@", tracker.id as CVarArg, startOfDay as NSDate, endOfDay as NSDate)
            
            do {
                let cdEntries = try viewContext.fetch(request)
                if let cdEntry = cdEntries.first {
                    cdEntry.isCompleted.toggle()
                } else {
                    _ = createTrackingEntry(for: tracker, date: date, isCompleted: true)
                }
                saveContext()
            } catch {
                print("Error toggling habit completion: \(error)")
            }
        }
        
        func fetchAchievements(for user: User) -> [Achievement] {
            let request: NSFetchRequest<CDAchievement> = CDAchievement.fetchRequest()
            request.predicate = NSPredicate(format: "user.id == %@", user.id as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \CDAchievement.dateAchieved, ascending: false)]
            do {
                let cdAchievements = try viewContext.fetch(request)
                return cdAchievements.map { Achievement(cdAchievement: $0) }
            } catch {
                print("Error fetching achievements: \(error)")
                return []
            }
        }
        
        func createReward(title: String, description: String, iconName: String, streakDays: Int, for user: User) -> Reward {
            guard let cdUser = fetchCDUser(with: user.id) else {
                fatalError("Failed to fetch CDUser")
            }
            let cdReward = CDReward(context: viewContext)
            cdReward.id = UUID()
            cdReward.title = title
            cdReward.rewardDescription = description
            cdReward.iconName = iconName
            cdReward.streakDays = Int16(streakDays)
            cdReward.user = cdUser
            saveContext()
            return Reward(cdReward: cdReward)
        }
        
        func fetchRewards(for user: User) -> [Reward] {
            let request: NSFetchRequest<CDReward> = CDReward.fetchRequest()
            request.predicate = NSPredicate(format: "user.id == %@", user.id as CVarArg)
            do {
                let cdRewards = try viewContext.fetch(request)
                return cdRewards.map { Reward(cdReward: $0) }
            } catch {
                print("Error fetching rewards: \(error)")
                return []
            }
        }
        
        func resetAllData() {
            let entityNames = ["User", "Tracker", "TrackingEntry", "Achievement", "Reward"]
            for entityName in entityNames {
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try viewContext.execute(deleteRequest)
                } catch {
                    print("Error resetting data for entity \(entityName): \(error)")
                }
            }
            saveContext()
        }
        
        // Helper methods to fetch Core Data objects using UUID
        private func fetchCDUser(with id: UUID) -> CDUser? {
            let request: NSFetchRequest<CDUser> = CDUser.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            
            do {
                return try viewContext.fetch(request).first
            } catch {
                print("Error fetching CDUser: \(error)")
                return nil
            }
        }
        
        private func fetchCDTracker(with id: UUID) -> CDTracker? {
            let request: NSFetchRequest<CDTracker> = CDTracker.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            
            do {
                return try viewContext.fetch(request).first
            } catch {
                print("Error fetching CDTracker: \(error)")
                return nil
            }
        }
    }
