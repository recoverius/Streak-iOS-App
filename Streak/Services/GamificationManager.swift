//
//  GamificationManager.swift
//  Streak
//
//  Created by Ilya Golubev on 17/09/2024.
//

import Foundation

class GamificationManager {
    static let shared = GamificationManager()
    
    private let coreDataManager = CoreDataManager.shared
    
    private init() {}
    
    func checkAndAwardAchievements(for user: User, tracker: Tracker, streak: Int) -> [Achievement] {
        var newAchievements: [Achievement] = []
        
        // Check for streak-based achievements
        if streak >= 7 && !user.achievements.contains(where: { $0.id == UUID(uuidString: "week-warrior")! }) {
            let achievement = coreDataManager.createAchievement(
                title: "Week Warrior",
                description: "Maintain a 7-day streak",
                iconName: "star.circle.fill",
                for: user
            )
            newAchievements.append(achievement)
        }
        
        if streak >= 30 && !user.achievements.contains(where: { $0.id == UUID(uuidString: "monthly-master")! }) {
            let achievement = coreDataManager.createAchievement(
                title: "Monthly Master",
                description: "Maintain a 30-day streak",
                iconName: "star.square.fill",
                for: user
            )
            newAchievements.append(achievement)
        }
        
        // Check for completion-based achievements
        let totalCompletions = tracker.entries.filter { $0.isCompleted }.count
        if totalCompletions >= 50 && !user.achievements.contains(where: { $0.id == UUID(uuidString: "half-century")! }) {
            let achievement = coreDataManager.createAchievement(
                title: "Half Century",
                description: "Complete a habit 50 times",
                iconName: "50.circle.fill",
                for: user
            )
            newAchievements.append(achievement)
        }
        
        return newAchievements
    }
    
    func calculateRewards(for achievements: [Achievement], user: User) -> [Reward] {
        // In a real app, you might have more complex logic here
        return achievements.map { achievement in
            coreDataManager.createReward(
                title: "Reward for \(achievement.title)",
                description: "You've earned a reward for achieving \(achievement.title)!",
                iconName: "gift.fill",
                streakDays: 0,  // We're not using this field for now
                for: user
            )
        }
    }
}
