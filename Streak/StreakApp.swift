//
//  StreakApp.swift
//  Streak
//
//  Created by Ilya Golubev on 17/09/2024.
//

import SwiftUI
import AVFoundation



func registerTransformers() {
    ValueTransformer.setValueTransformer(DateArrayTransformer(), forName: NSValueTransformerName("DateArrayTransformer"))
}


@main
struct HabitTrackerApp: App {
    let persistenceController = CoreDataManager.shared
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    init() {
        registerTransformers()
        setupAppearance()
        checkNotificationPermissions()
        setupAudioSession()
        initializeSoundManager()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers, .duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio session set up successfully")
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func initializeSoundManager() {
        _ = SoundManager.shared
        print("SoundManager initialized")
    }
    
//    @State private var isFirstLaunch = true

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .environmentObject(settingsViewModel)
                .onAppear {
//                    #if DEBUG
//                    if isFirstLaunch {
//                        TestDataGenerator.shared.generateTestData()
//                        isFirstLaunch = false
//                    }
//                    #endif
                }
        }
        }
    
    private func setupAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.customPalette.richBlack)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func checkNotificationPermissions() {
        NotificationManager.shared.checkPermissionStatus { status in
            if status == .notDetermined {
                settingsViewModel.requestNotificationPermission()
            }
        }
    }
}



class TestDataGenerator {
    static let shared = TestDataGenerator()
    private let coreDataManager = CoreDataManager.shared
    
    private init() {}
    
    func generateTestData() {
        // Create a test user if not exists
        let user = coreDataManager.fetchUser() ?? coreDataManager.createUser(name: "Test User", avatarName: "person.circle")
        
        // Create test trackers
        let trackers = [
            ("Morning Workout", "figure.walk", HabitTarget.daily),
            ("Read a Book", "book.fill", HabitTarget.weekly),
            ("Meditate", "brain.head.profile", HabitTarget.custom(days: 5)),
            ("Drink Water", "drop.fill", HabitTarget.daily)
        ]
        
        for (name, iconName, target) in trackers {
            let tracker = coreDataManager.createTracker(name: name, iconName: iconName, target: target, for: user)
            generateEntriesForTracker(tracker)
        }
    }
    
    private func generateEntriesForTracker(_ tracker: Tracker) {
        let calendar = Calendar.current
        let today = Date()
        let threeWeeksAgo = calendar.date(byAdding: .day, value: -21, to: today)!
        
        var currentDate = threeWeeksAgo
        while currentDate <= today {
            let shouldComplete = Double.random(in: 0...1) > 0.3 // 70% chance of completion
            if shouldComplete {
                _ = coreDataManager.createTrackingEntry(for: tracker, date: currentDate, isCompleted: true)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
    }
}
