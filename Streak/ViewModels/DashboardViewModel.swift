//
//  DashboardViewModel.swift
//  Streak
//
//  Created by Ilya Golubev on 17/09/2024.
//
import Foundation
import Combine
import CoreData

class DashboardViewModel: ObservableObject {
    @Published var trackers: [Tracker] = []
    @Published var currentUser: User?
    @Published var currentDate: Date = Date()
    @Published var newAchievements: [Achievement] = []
    @Published var currentNewAchievement: Achievement?
    @Published var newRewards: [Reward] = []
    @Published var todayTrackers: [Tracker] = []
    @Published var longestStreak: Int = 0 
    
    private let coreDataManager = CoreDataManager.shared
    private let gamificationManager = GamificationManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadData()
        setupDateUpdater()
    }
    
    func loadData() {
        currentUser = coreDataManager.fetchUser()
        if currentUser == nil {
            currentUser = coreDataManager.createUser(name: "New User", avatarName: nil)
        }
        
        if let user = currentUser {
            trackers = coreDataManager.fetchTrackers(for: user)
            longestStreak = trackers.map { calculateCurrentStreak(for: $0) }.max() ?? 0  // Add this line
        }
    }
    
    func frequencyText(for tracker: Tracker) -> String {
        switch tracker.target {
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .custom(let days):
            return "Every \(days) days"
        }
    }
    func isScheduledDay(for tracker: Tracker, on date: Date) -> Bool {
        let calendar = Calendar.current
        let frequencyDays: Int

        switch tracker.target {
        case .daily:
            frequencyDays = 1
        case .weekly:
            frequencyDays = 7
        case .custom(let days):
            frequencyDays = days
        }

        // Use the start date of the habit instead of the creation date
        guard let daysSinceStart = calendar.dateComponents([.day], from: tracker.startDate, to: date).day else {
            return false
        }

        // Check if the current date is on or after the start date
        guard date >= tracker.startDate else {
            return false
        }

        return daysSinceStart % frequencyDays == 0
    }

    func deleteHabit(_ tracker: Tracker) {
        coreDataManager.deleteTracker(tracker)
        loadData() // Reload data to reflect changes
    }

    func toggleHabitCompletion(for tracker: Tracker, on date: Date) {
        coreDataManager.toggleHabitCompletion(for: tracker, on: date)
        loadData() // Reload data to reflect changes
        
        // Play checkmark sound
        SoundManager.shared.playSound("checkmark")
        
        // Check if all items for the day are completed
        let allCompleted = trackers.allSatisfy { tracker in
            getCompletionStatus(for: tracker, on: date)
        }
        
        if allCompleted {
            SoundManager.shared.playSound("all_complete")
        }
        
        // Check for new achievements
        if let user = currentUser {
            let streak = calculateCurrentStreak(for: tracker)
            let achievements = gamificationManager.checkAndAwardAchievements(for: user, tracker: tracker, streak: streak)
            if !achievements.isEmpty {
                newAchievements = achievements
                currentNewAchievement = achievements.first
                newRewards = gamificationManager.calculateRewards(for: achievements, user: user)
                
                // Update user with new achievements
                var updatedUser = user
                updatedUser.achievements.append(contentsOf: achievements)
                coreDataManager.updateUser(updatedUser)
            }
        }
    }
    
    func getCompletionStatus(for tracker: Tracker, on date: Date) -> Bool {
        let calendar = Calendar.current
        let frequencyDays: Int

        switch tracker.target {
        case .daily:
            frequencyDays = 1
        case .weekly:
            frequencyDays = 7
        case .custom(let days):
            frequencyDays = days
        }

        // Calculate the number of days since the habit was created
        guard let daysSinceCreation = calendar.dateComponents([.day], from: tracker.createdDate, to: date).day else {
            return false
        }

        // Determine if the current date is a scheduled day
        if daysSinceCreation % frequencyDays != 0 {
            return false
        }

        return tracker.entries.contains { entry in
            calendar.isDate(entry.date, inSameDayAs: date) && entry.isCompleted
        }
    }
    
    func dismissCurrentAchievement() {
            currentNewAchievement = newAchievements.dropFirst().first
        }

    func updateHabit(habit: Tracker, name: String, iconName: String, colorName: String, target: HabitTarget, startDate: Date) {
        coreDataManager.updateTracker(habit, name: name, iconName: iconName, colorName: colorName, target: target, startDate: startDate)
        loadData() // Reload data to reflect changes
    }

    func addNewHabit(name: String, iconName: String, colorName: String, target: HabitTarget, startDate: Date) {
        guard let user = currentUser else { return }
        _ = coreDataManager.createTracker(name: name, iconName: iconName, colorName: colorName, target: target, startDate: startDate, for: user)
        loadData() // Reload data to reflect changes
        objectWillChange.send() // Notify observers that the object has changed
    }
    
    func calculateCurrentStreak(for tracker: Tracker) -> Int {
        let sortedEntries = tracker.entries.sorted { $0.date > $1.date }
        var streak = 0
        let calendar = Calendar.current
        var currentDate = Date()
        
        for entry in sortedEntries {
            if calendar.isDate(entry.date, inSameDayAs: currentDate) && entry.isCompleted {
                streak += 1
                if let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate) {
                    currentDate = previousDate
                } else {
                    break
                }
            } else if calendar.isDate(entry.date, inSameDayAs: currentDate) && !entry.isCompleted {
                // Streak is broken
                break
            } else if calendar.compare(entry.date, to: currentDate, toGranularity: .day) == .orderedAscending {
                // We've reached a day before the current date without a completed entry
                break
            } else {
                // Move to the previous day
                if let newDate = calendar.date(byAdding: .day, value: -1, to: currentDate) {
                    currentDate = newDate
                } else {
                    break
                }
            }
        }
        
        return streak
    }

    func refreshData() {
        loadData()
        currentDate = Date()
    }

    private func setupDateUpdater() {
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.currentDate = Date()
            }
            .store(in: &cancellables)
    }
}
